import { withPluginApi } from "discourse/lib/plugin-api";
import { authorizesOneOrMoreExtensions } from "discourse/lib/utilities";
import discourseComputed from "discourse-common/utils/decorators";

export default {
  name: "restrict-uploads",
  initialize() {
    withPluginApi("0.8", api => {
      let currentUser = api.getCurrentUser();
      let canUpload;

      if (currentUser) {
        canUpload =
          currentUser.trust_level >= settings.restrict_to_trust_level ||
          currentUser.staff;
      }

      api.modifyClass("controller:composer", {
        @discourseComputed
        allowUpload() {
          if (canUpload && authorizesOneOrMoreExtensions()) {
            return true;
          }
        }
      });

      api.modifyClass("component:composer-editor", {
        _bindUploadTarget() {
          if (canUpload) {
            this._super();
          }
        },
        @discourseComputed("composer.requiredCategoryMissing")
        replyPlaceholder(requiredCategoryMissing) {
          if (canUpload) {
            return this._super();
          } else {
            return "composer.reply_placeholder_no_images";
          }
        }
      });
    });
  }
};
