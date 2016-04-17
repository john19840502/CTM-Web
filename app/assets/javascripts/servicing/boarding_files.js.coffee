
App.initializeServicingBoardingFilesPage = (bfDownloadLinkUrl) ->
  JobStatus.initializeJobStatus
    onComplete: (job) -> addDownloadUrlFor(job, bfDownloadLinkUrl)
  
urlTemplate = _.template "<a href='{{url}}'>{{text}}</a>"

addDownloadUrlFor = (job, bfDownloadLinkUrl) ->
  console.log job
  console.log bfDownloadLinkUrl
  bfContainer = $(job).closest('.boarding-file-container')
  urlContainer = bfContainer.find('.download-url')
  currentText = urlContainer.text()
  boardingFileId = bfContainer.data('id')
  $.ajax bfDownloadLinkUrl,
    type: 'get'
    data: { id: boardingFileId }
    success: (data) ->
      $(urlContainer).html(urlTemplate { url: data, text: currentText })
