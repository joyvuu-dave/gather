SimpleForm.setup do |config|
  config.wrappers :ranged_datetime, tag: 'div', class: 'form-group col-md-6', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly

    b.use :label, class: 'control-label'
    b.use :input, class: 'form-control'

    b.use :hint,  wrap_with: { tag: 'p', class: 'hint' }
    b.use :error, wrap_with: { tag: 'span', class: 'error' }
  end
end
