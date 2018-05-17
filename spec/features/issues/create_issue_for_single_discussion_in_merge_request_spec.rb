require 'rails_helper'

feature 'Resolve an open discussion in a merge request by creating an issue', :js do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository, only_allow_merge_if_all_discussions_are_resolved: true) }
  let(:merge_request) { create(:merge_request, source_project: project) }
  let!(:discussion) { create(:diff_note_on_merge_request, noteable: merge_request, project: project).to_discussion }

  def resolve_discussion_link_selector
    url = new_project_issue_path(project, discussion_to_resolve: discussion.id, merge_request_to_resolve_discussions_of: merge_request.iid)
    title = 'Resolve this discussion in a new issue'
    %Q{a.discussion-create-issue-btn[data-original-title="#{title}"][href="#{url}"]}
  end

  describe 'As a user with access to the project' do
    before do
      project.add_master(user)
      sign_in user
      visit project_merge_request_path(project, merge_request)
    end

    context 'with the internal tracker disabled' do
      before do
        project.project_feature.update_attribute(:issues_access_level, ProjectFeature::DISABLED)
        visit project_merge_request_path(project, merge_request)
      end

      it 'does not show a link to create a new issue' do
        expect(page).not_to have_selector resolve_discussion_link_selector
      end
    end

    context 'resolving the discussion', :js do
      before do
        click_button 'Resolve discussion'
      end

      it 'hides the link for creating a new issue' do
        expect(page).not_to have_selector resolve_discussion_link_selector
      end

      # TODO: https://gitlab.com/gitlab-org/gitlab-ce/issues/45985
      xit 'shows the link for creating a new issue when unresolving a discussion' do
        page.within '.diff-content' do
          click_button 'Unresolve discussion'

          expect(page).to have_selector resolve_discussion_link_selector
        end
      end
    end

<<<<<<< HEAD
    # TODO: https://gitlab.com/gitlab-org/gitlab-ce/issues/45985
    xit 'has a link to create a new issue for a discussion' do
      new_issue_link = new_project_issue_path(project, discussion_to_resolve: discussion.id, merge_request_to_resolve_discussions_of: merge_request.iid)

      expect(page).to have_link 'Resolve this discussion in a new issue', href: new_issue_link
=======
    it 'has a link to create a new issue for a discussion' do
      page.within '.diff-content' do
        expect(page).to have_selector resolve_discussion_link_selector
      end
>>>>>>> f67fa26c271... Undo unrelated changes from b1fa486b74875df8cddb4aab8f6d31c036b38137
    end

    context 'creating the issue' do
      before do
        find(resolve_discussion_link_selector).click
      end

      # TODO: https://gitlab.com/gitlab-org/gitlab-ce/issues/45985
      xit 'has a hidden field for the discussion' do
        discussion_field = find('#discussion_to_resolve', visible: false)

        expect(discussion_field.value).to eq(discussion.id.to_s)
      end

      # TODO: https://gitlab.com/gitlab-org/gitlab-ce/issues/45985
      # it_behaves_like 'creating an issue for a discussion'
    end
  end

  describe 'as a reporter' do
    before do
      project.add_reporter(user)
      sign_in user
      visit new_project_issue_path(project, merge_request_to_resolve_discussions_of: merge_request.iid,
                                            discussion_to_resolve: discussion.id)
    end

    it 'Shows a notice to ask someone else to resolve the discussions' do
      expect(page).to have_content("The discussion at #{merge_request.to_reference}"\
                                   " (discussion #{discussion.first_note.id}) will stay unresolved."\
                                   " Ask someone with permission to resolve it.")
    end
  end
end
