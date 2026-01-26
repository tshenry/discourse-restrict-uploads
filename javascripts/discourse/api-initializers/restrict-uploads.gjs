import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";
import discourseComputed from "discourse-common/utils/decorators";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();
  const minTrust = settings.restrict_to_trust_level;

  let canUpload = false;

  if (currentUser?.trust_level >= minTrust || currentUser?.staff) {
    canUpload = true;
  }

  api.modifyClass(
    "service:composer",
    (SuperClass) =>
      class extends SuperClass {
        @discourseComputed
        allowUpload() {
          return super.allowUpload && canUpload;
        }
      }
  );

  api.modifyClass(
    "component:composer-editor",
    (SuperClass) =>
      class extends SuperClass {
        get replyPlaceholder() {
          if (!canUpload) {
            const richEditorEnabled =
              this.siteSettings.rich_editor && this.currentUser?.useRichEditor;

            const key = richEditorEnabled
              ? "composer.reply_placeholder_rte_no_images"
              : "composer.reply_placeholder_no_images";

            return i18n(key);
          }

          return super.replyPlaceholder;
        }
      }
  );

  api.addComposerUploadHandler(["*"], () => {
    return canUpload;
  });
});
