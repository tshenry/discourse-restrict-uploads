# frozen_string_literal: true

require_relative "page_objects/components/composer_upload"

RSpec.describe "Restrict uploads" do
  let!(:theme) { upload_theme_component }
  fab!(:admin)
  fab!(:user_tl0) { Fabricate(:user, trust_level: 0) }
  fab!(:user_tl1) { Fabricate(:user, trust_level: 1) }
  fab!(:user_tl2) { Fabricate(:user, trust_level: 2) }
  fab!(:category)
  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:post) { Fabricate(:post, topic:) }

  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:composer_upload) { PageObjects::Components::ComposerUpload.new }
  let(:dialog) { PageObjects::Components::Dialog.new }

  context "when restrict_to_trust_level is set to 1" do
    before do
      theme.update_setting(:restrict_to_trust_level, 1)
      theme.save!
    end

    it "prevents trust level 0 users from uploading" do
      sign_in(user_tl0)
      topic_page.open_new_topic

      expect(composer_upload).to have_no_upload_button
    end

    it "shows custom placeholder for trust level 0 users" do
      sign_in(user_tl0)
      topic_page.open_new_topic

      placeholder_text = find(".d-editor-input")["placeholder"]
      expect(placeholder_text).not_to include("images")
    end

    it "shows dialog when trust level 0 user attempts to upload a file" do
      sign_in(user_tl0)
      topic_page.open_new_topic

      attach_file("file-uploader", file_from_fixtures("logo.png", "images").path, make_visible: true)
      expect(dialog).to be_open
    end

    it "allows trust level 1 users to upload" do
      sign_in(user_tl1)
      topic_page.open_new_topic

      expect(composer_upload).to have_upload_button
    end

    it "allows trust level 1 user to upload file without restriction dialog" do
      sign_in(user_tl1)
      topic_page.open_new_topic

      attach_file("file-uploader", file_from_fixtures("logo.png", "images").path, make_visible: true)
      expect(dialog).to be_closed
    end

    it "allows trust level 2 users to upload" do
      sign_in(user_tl2)
      topic_page.open_new_topic

      expect(composer_upload).to have_upload_button
    end

    it "allows staff to upload regardless of trust level" do
      admin.update!(trust_level: 0)
      sign_in(admin)
      topic_page.open_new_topic

      expect(composer_upload).to have_upload_button
    end

    it "allows staff to upload file without restriction dialog even at low trust level" do
      admin.update!(trust_level: 0)
      sign_in(admin)
      topic_page.open_new_topic

      attach_file("file-uploader", file_from_fixtures("logo.png", "images").path, make_visible: true)
      expect(dialog).to be_closed
    end
  end

  context "when restrict_to_trust_level is set to 2" do
    before do
      theme.update_setting(:restrict_to_trust_level, 2)
      theme.save!
    end

    it "prevents trust level 1 users from uploading" do
      sign_in(user_tl1)
      topic_page.open_new_topic

      expect(composer_upload).to have_no_upload_button
    end

    it "shows dialog with correct trust level when trust level 1 user attempts to upload" do
      sign_in(user_tl1)
      topic_page.open_new_topic

      attach_file("file-uploader", file_from_fixtures("logo.png", "images").path, make_visible: true)
      expect(dialog).to be_open
    end

    it "allows trust level 2 users to upload" do
      sign_in(user_tl2)
      topic_page.open_new_topic

      expect(composer_upload).to have_upload_button
    end
  end

  context "when replying to a topic" do
    before do
      theme.update_setting(:restrict_to_trust_level, 1)
      theme.save!
    end

    it "prevents restricted users from uploading in replies" do
      sign_in(user_tl0)
      topic_page.visit_topic_and_open_composer(topic)

      expect(composer_upload).to have_no_upload_button
    end

    it "shows dialog when restricted user attempts to upload in reply" do
      sign_in(user_tl0)
      topic_page.visit_topic_and_open_composer(topic)

      attach_file("file-uploader", file_from_fixtures("logo.png", "images").path, make_visible: true)
      expect(dialog).to be_open
    end

    it "allows permitted users to upload in replies" do
      sign_in(user_tl1)
      topic_page.visit_topic_and_open_composer(topic)

      expect(composer_upload).to have_upload_button
    end
  end
end
