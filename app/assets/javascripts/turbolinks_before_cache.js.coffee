document.addEventListener 'turbolinks:before-cache', ->
  # Select2
  if $('.select2-input').hasClass('select2-hidden-accessible')
    $('.select2-input').select2 'destroy'

  return
