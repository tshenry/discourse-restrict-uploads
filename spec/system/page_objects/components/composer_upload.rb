# frozen_string_literal: true

module PageObjects
  module Components
    class ComposerUpload < PageObjects::Components::Base
      SELECTOR = ".d-editor-button-bar button.upload"

      def has_upload_button?
        page.has_css?(SELECTOR)
      end

      def has_no_upload_button?
        page.has_no_css?(SELECTOR)
      end
    end
  end
end
