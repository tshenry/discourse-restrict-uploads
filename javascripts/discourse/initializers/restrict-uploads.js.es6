import { withPluginApi } from "discourse/lib/plugin-api";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

const PLUGIN_ID = "discourse-restrict-uploads";

export default {
  name: PLUGIN_ID,
  initialize() {
    withPluginApi((api) => {
      let currentUser = api.getCurrentUser();
      let canUpload;

      if (currentUser) {
        canUpload =
          currentUser.trust_level >= settings.restrict_to_trust_level ||
          currentUser.staff;
      }

      api.modifyClass("controller:composer", {
        pluginId: PLUGIN_ID,

        @discourseComputed
        allowUpload() {
          return this._super() && canUpload;
        },
      });

      api.modifyClass("component:composer-editor", {
        pluginId: PLUGIN_ID,

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
            return I18n.t("composer.reply_placeholder_no_images");
          }
        },
      });
    });
  },
};