function updateTagOptions (tags: string[], input, addTags = true): void {
  tags.forEach((tag) => {
    if (addTags) {
      input.addOption({ value: tag, text: tag })
    } else {
      input.removeOption({ value: tag, text: tag })
    }
  })
  input.refreshOptions(false)
}

function getTags (modelId: string): string[] {
  const selector = `[data-bulk-item-tags="${modelId}"]`
  const tagLinks = document.querySelectorAll(
    selector
  )
  return Array.prototype.slice
    .call(tagLinks)
    .map((tag: HTMLAnchorElement) => tag.innerHTML)
}

function handleCheckboxChange (event): void {
  const target = event.target as HTMLInputElement
  const { name } = target
  event.preventDefault()
  console.log({ target }, { name })
  // the bulk select checkbox has been selected
  if (target.name === 'bulk-select-all') {
    document
      .querySelectorAll('[data-bulk-item]')
      .forEach((checkbox: HTMLInputElement) => {
        checkbox.checked = target.checked
      })
  } else {
    // a single checkbox item has been selected.
    const modelId = target.getAttribute('data-bulk-item') as string
    if (modelId != null) {
      const tags = getTags(modelId)

      if (tags.length > 0 && window.tagInputs != null) {
        const { tagInputs } = window
        console.log({ tagInputs })
        window.tagInputs.forEach((input) => {
          updateTagOptions(tags, input[0].selectize, target.checked)
        })
      }
    }
  }
}

document.addEventListener('turbolinks:load', () => {
  const bulkEditTable = document.querySelector(
    '[data-bulk-edit]'
  )
  if (bulkEditTable != null) {
    bulkEditTable.removeEventListener('change', handleCheckboxChange)
    bulkEditTable.addEventListener('change', handleCheckboxChange)
  }
})
