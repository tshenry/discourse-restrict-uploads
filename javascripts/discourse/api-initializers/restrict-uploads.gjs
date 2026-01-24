import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();
  const minTrust = settings.restrict_to_trust_level;

  let canUpload = false;

  if (currentUser?.trust_level >= minTrust || currentUser?.staff) {
    canUpload = true;
  }

  api.modifyClass("service:composer", {
    pluginId: "discourse-restrict-uploads",

    get allowUpload() {
      return this._super() && canUpload;
    },
  });

  api.modifyClass("component:composer-editor", {
    pluginId: "discourse-restrict-uploads",

    get replyPlaceholder() {
      if (!canUpload) {
        const richEditorEnabled =
          this.siteSettings.rich_editor && this.currentUser?.useRichEditor;

        const key = richEditorEnabled
          ? "composer.reply_placeholder_rte_no_images"
          : "composer.reply_placeholder_no_images";

        return i18n(key);
      }

      return this._super();
    },
  });

  api.addComposerUploadHandler(["*"], () => {
    return canUpload;
  });
});
