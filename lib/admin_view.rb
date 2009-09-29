module AdminView
  include AdminView::Backend
  include AdminView::Actions
  include AdminView::Forms
  include AdminView::Filters
  include AdminView::ResourceCard
  include AdminView::GridTable
  include AdminView::ListFor
  include AdminView::PresentationBuilder
  include AdminView::Presenter
  include AdminView::ElegantPresentation
end

ActionView::Base.send :include, AdminView

