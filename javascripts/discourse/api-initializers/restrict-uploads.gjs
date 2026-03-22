import { action } from "@ember/object";
import { schedule } from "@ember/runloop";
import { service } from "@ember/service";
import { apiInitializer } from "discourse/lib/api";
import { AUTO_GROUPS } from "discourse/lib/constants";
import { i18n } from "discourse-i18n";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();
  const siteSettings = api.container.lookup("service:site-settings");
  const hasChat = siteSettings.chat_enabled && currentUser?.has_chat_enabled;

  const currentUserGroupIds =
    currentUser?.groups?.map((group) => group.id) ?? [];
  const allowedGroupIds =
    settings.restricted_to_groups?.split("|").map(Number) || [];

  const canUpload = allowedGroupIds.some(
    (groupId) =>
      currentUserGroupIds.includes(groupId) ||
      groupId === AUTO_GROUPS.everyone.id
  );

  if (!canUpload) {
    document.documentElement.classList.add("cannot-upload-files");
  }

  const noImagePlaceholders = new Set([
    "composer.reply_placeholder_rte",
    "composer.reply_placeholder",
  ]);

  api.registerValueTransformer(
    "composer-editor-reply-placeholder",
    ({ value }) =>
      !canUpload && noImagePlaceholders.has(value)
        ? `${value}_no_images`
        : value
  );

  function dialogUploadRestriction() {
    this.dialog.alert(i18n(themePrefix("restricted_upload")));
  }

  function overrideUppy(uppyUpload) {
    const { uppyInstance } = uppyUpload.uppyWrapper;
    const originalHandler = uppyInstance.opts.onBeforeFileAdded;

    uppyInstance.opts.onBeforeFileAdded = (currentFile) => {
      if (!canUpload) {
        dialogUploadRestriction.call(this);
        return false;
      }

      return originalHandler(currentFile);
    };
  }

  api.modifyClass(
    "component:composer-editor",
    (Superclass) =>
      class extends Superclass {
        @service dialog;

        @action
        _composerEditorInitEditor(elem) {
          if (!this.composer.allowUpload) {
            return;
          }

          super._composerEditorInitEditor(elem);
          overrideUppy.apply(this, [this.uppyComposerUpload]);
        }
      }
  );

  if (hasChat) {
    api.modifyClass(
      "component:chat-composer-uploads",
      (Superclass) =>
        class extends Superclass {
          @service dialog;

          didInsertElement() {
            super.didInsertElement(...arguments);

            schedule("afterRender", () => {
              overrideUppy.apply(this, [this.uppyUpload]);
            });
          }
        }
    );

    api.modifyClass(
      "component:chat-composer-dropdown",
      (Superclass) =>
        class extends Superclass {
          @service dialog;

          @action
          doubleClick(event) {
            if (!canUpload) {
              event.preventDefault();
              dialogUploadRestriction.call(this);
              return;
            }

            super.doubleClick(event);
          }
        }
    );
  }
});
