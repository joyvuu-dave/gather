require "rails_helper"

feature "user form" do
  let(:admin) { create(:admin) }
  let(:photographer) { create(:photographer) }
  let(:user) { create(:user, :with_photo) }
  let!(:household) { create(:household, name: "Gingerbread") }
  let!(:household2) { create(:household, name: "Potatoheads") }

  around { |ex| with_user_home_subdomain(actor) { ex.run } }

  before do
    @old_max_size = Settings.photos.max_size_mb
    Settings.photos.max_size_mb = 1
    login_as(actor, scope: :user)
  end

  after do
    Settings.photos.max_size_mb = @old_max_size
  end

  shared_examples_for "editing user" do
    scenario "edit user", js: true do
      visit(edit_user_path(user))
      expect_image_upload(mode: :existing, path: /cooper/)
      drop_in_dropzone(fixture_file_path("chomsky.jpg"))
      expect_image_upload(mode: :dz_preview)
      fill_in("First Name", with: "Zoor")
      click_on("Update User")

      expect_success
      expect_title(/Zoor/)
      expect_profile_photo(/chomsky/)
    end
  end

  context "as admin" do
    let(:actor) { admin }

    it_behaves_like "editing user"

    scenario "new user", js: true do
      visit(new_user_path)
      expect_no_image_upload
      drop_in_dropzone(fixture_file_path("cooper.jpg"))
      expect_image_upload(mode: :dz_preview)
      click_on("Create User")

      expect_validation_error
      expect_image_upload(mode: :existing, path: /cooper/)
      fill_in("First Name", with: "Foo")
      fill_in("Last Name", with: "Barre")
      fill_in("Email", with: "foo@example.com")
      select2("Ginger", from: "user_household_id")
      fill_in("Mobile", with: "5556667777")
      click_on("Create User")

      expect_success
      expect_title(/Foo Barre/)
      expect_profile_photo(/cooper/)
    end

    scenario "editing household", js: true do
      visit(edit_user_path(user))
      click_on("move them to another household")
      select2("Potatoheads", from: "user_household_id")
      click_on("Update User")

      expect_success
      expect(page).to have_css(%Q{a.household[href$="/households/#{household2.id}"]})
    end

    scenario "deleting photo", js: true do
      # Uploading without saving
      visit(edit_user_path(user))
      expect_image_upload(mode: :existing, path: /cooper/)
      drop_in_dropzone(fixture_file_path("chomsky.jpg"))

      # Uploading and deleting without saving
      visit(edit_user_path(user))
      expect_image_upload(mode: :existing, path: /cooper/)
      drop_in_dropzone(fixture_file_path("chomsky.jpg"))
      delete_from_dropzone

      # Deleting existing photo without saving
      visit(edit_user_path(user))
      expect_image_upload(mode: :existing, path: /cooper/)
      delete_from_dropzone

      # Deleting existing AND saving
      visit(edit_user_path(user))
      expect_image_upload(mode: :existing, path: /cooper/)
      delete_from_dropzone
      click_on("Update User")

      expect_success
      expect_profile_photo(/missing/)
    end

    describe "upload validations" do
      scenario "too big", js: true do
        visit(edit_user_path(user))
        drop_in_dropzone(fixture_file_path("large.jpg"))
        expect(page).to have_css("form.dropzone .dz-error-message", text: /too big/)
      end

      scenario "wrong format", js: true do
        visit(edit_user_path(user))
        drop_in_dropzone(fixture_file_path("article.pdf"))
        expect(page).to have_css("form.dropzone .dz-error-message", text: /Photo has incorrect type/)
      end
    end
  end

  context "as photographer" do
    let(:actor) { photographer }

    scenario "update photo", js: true do
      visit(user_path(user))
      click_on("Edit Photo")
      expect_image_upload(mode: :upload_message)
      drop_in_dropzone(fixture_file_path("chomsky.jpg"))
      expect_image_upload(mode: :dz_preview)
      click_on("Save Photo")
      expect_success
      expect_profile_photo(/chomsky/)
    end
  end

  context "as regular user" do
    let(:actor) { user }

    it_behaves_like "editing user"
  end
end
