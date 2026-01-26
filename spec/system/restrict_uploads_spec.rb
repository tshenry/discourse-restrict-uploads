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

    it "allows trust level 1 users to upload" do
      sign_in(user_tl1)
      topic_page.open_new_topic

      expect(composer_upload).to have_upload_button
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

    it "allows permitted users to upload in replies" do
      sign_in(user_tl1)
      topic_page.visit_topic_and_open_composer(topic)

      expect(composer_upload).to have_upload_button
    end
  end
end
