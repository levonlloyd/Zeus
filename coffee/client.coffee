# Are we showing the tabs already.  If not we will load on show
showingInstances = false
showingImages = false
showingKeyPairs = false
showingZones = false
showingElasticIPs = false
showingSecurityGroups = false
showingVolumes = false
showingSnapshots = false
imagesData = []
instancesData = []
elasticIPData = []
volumeData = []

setupInstances = () ->
    $('#instances').jqGrid
      datatype: 'local'
      height: 500
      width: 1200
      ondblClickRow: (rowid, rowIndex, colIndex, e) ->
          showInstancesDialog rowid
      colNames: [
        'Architecture',
        'Availability Zone',
        'DNS Name',
        'Security Group',
        'AMI',
        'Instance ID',
        'State',
        'Launch Time',
        'Private DNS Name',
        'Platform',
        'Key Name',
        'Root Device Type'
      ],
      colModel:[
        {name:'architecture',index:'architecture',width:80},
        {name:'az',index:'az',width:120},
        {name:'dnsName',index:'dnsName',width:50},
        {name:'secGroup',index:'secGroup',width:80},
        {name:'ami',index:'ami',width:30},
        {name:'instanceId',index:'instanceId',width:40},
        {name:'state',index:'state',width:45},
        {name:'launchTime',index:'launchTime',width:60},
        {name:'privateDnsName',index:'privateDnsName',width:30},
        {name:'platform',index:'platform',width:60},
        {name:'keyName',index:'keyName',width:30},
        {name:'rootDeviceType',index:'rootDeviceType',width:100}
      ],
      multiselect: true,
      caption: 'Instances'

showInstances = (data) ->
  if not showingInstances
    $("#instances").jqGrid('addRowData',i+1,dataPoint) for dataPoint,i in data
    instancesData = data
  $("#instances-show").hide()
  showingInstances = true

showImagesDialog = (rowNum) ->
  row = imagesData[rowNum - 1]
  $('.image-reset').empty()
  $('#imaged-architecture').append(row.architecture)
  $('#imaged-id').append(row.imageId)
  $('#imaged-location').append(row.imageLocation)
  $('#imaged-owner').append(row.imageOwnerId)
  $('#imaged-state').append(row.imageState)
  $('#imaged-type').append(row.imageType)
  $('#imaged-public').append(row.isPublic)
  $('#imaged-name').append(row.name)
  $('#imaged-kernel').append(row.kernelId)
  $('#imaged-ramdisk').append(row.ramDiskId)
  $('#imaged-rootDevice').append(row.rootDeviceType)
  $('#imaged-description').append(row.description)
  $('#imaged-tags').append(row.tags.join(','))
  $("#image-dialog").dialog 'open'

showVolumesDialog = (rowNum) ->
  row = volumeData[rowNum - 1]
  $('.volume-reset').empty()
  $("#volume-dialog").dialog 'open'

showInstancesDialog = (rowNum) ->
  row = instancesData[rowNum - 1]
  $('.instance-reset').empty()
  $('#instanced-architecture').append(row.architecture)
  $('#instanced-id').append(row.instanceId)
  $('#instanced-location').append(row.az)
  $('#instanced-ami').append(row.ami)
  $('#instanced-state').append(row.state)
  $('#instanced-launchTime').append(row.launchTime)
  $('#instanced-publicDNS').append(row.dnsName)
  $('#instanced-keyName').append(row.keyName)
  $('#instanced-platform').append(row.platform)
  $('#instanced-privateDNS').append(row.privateDnsName)
  $('#instanced-rootDevice').append(row.rootDeviceType)
  $('#instanced-secGroup').append(row.secGroup)
  $('#instanced-tags').append(row.tags.join(','))

  consoleOutputHandler = (content) ->
    $('#instanced-co').empty().append("<textarea cols=\"100\" rows=\"20\">" + content + "</textarea>")
  getConsoleOutput row.instanceId, consoleOutputHandler, handleFailure
  $('#instance-dialog').dialog 'open'

setupImages = () ->
  $('#images').jqGrid
    datatype: 'local'
    height: 500
    width: 1200
    ondblClickRow: (rowid, rowIndex, colIndex, e) ->
      showImagesDialog rowid
    colNames: [
      'Image ID',
      'Image Location',
      'Image State',
      'Image Owner',
      'Public',
      'Architecture',
      'Image Type',
      'Kernel ID',
      'Ram Disk ID',
      'Name',
      'Description',
      'Root Device Type'
    ],
    colModel:[
      {name:'imageId',index:'imageId',width:80},
      {name:'imageLocation',index:'imageLocation',width:120},
      {name:'imageState',index:'imageState',width:50},
      {name:'imageOwnerId',index:'imageOwnerId',width:80},
      {name:'isPublic',index:'isPublic',width:30},
      {name:'architecture',index:'architecture',width:40},
      {name:'imageType',index:'imageType',width:45},
      {name:'kernelId',index:'kernelId',width:60},
      {name:'ramdiskId',index:'ramdiskId',width:30},
      {name:'name',index:'name',width:60},
      {name:'description',index:'description',width:30},
      {name:'rootDeviceType',index:'rootDeviceType',width:100}
    ],
    multiselect: true,
    caption: 'AMIs'

showImages = (data) ->
  if not showingImages
    $("#images").jqGrid('addRowData',i+1,dataPoint) for dataPoint,i in data
    imagesData = data
  $("#instances-show").hide()
  showingImages = true

setupKeyPairs = () ->
  $('#key-pairs').jqGrid
    datatype: 'local'
    height: 200
    width: 1200
    colNames: [
      'Key Name'
      'Key Fingerprint'
    ],
    colModel: [
      {name:'keyName',index:'keyName',width:200},
      {name:'keyFingerprint',index:'keyFingerprint',width:200}
    ]
    multiselect: true,
    caption: 'Key Pairs'

showKeyPairs = (data) ->
  if not showingKeyPairs
    $("#key-pairs").jqGrid('addRowData',i+1,dataPoint) for dataPoint,i in data
  showingKeyPairs = true

setupSecurityGroups = () ->
  $('#security-groups').jqGrid
    datatype: 'local'
    height: 200
    width: 1200
    colNames: [
      'Group Name'
      'Group Description'
    ]
    colModel: [
      {name:'name',index:'name',width:200}
      {name:'description',index:'description',width:200}
    ]
    multiselect: false
    caption: 'Security Groups'

showSecurityGroups = (data) ->
  if not showingSecurityGroups
    $('#security-groups').jqGrid('addRowData', i+1, dataPoint) for dataPoint, i in data
  showingSecurityGroups = true

setupElasticIPs = () ->
  $('#elastic-ips').jqGrid
    datatype: 'local'
    height: 200
    width: 1200
    colNames: [
      'IP Address'
      'Instance ID'
    ],
    colModel: [
      {name:'ip',index:'ip',width:200}
      {name:'instance',index:'instance',width:200}
    ]
    multiselect: false
    caption:'Elastic IPs'

showElasticIPs = (data) ->
  if not showingElasticIPs
    $('#elastic-ips').jqGrid('addRowData', i+1, dataPoint) for dataPoint, i in data
    showingElasticIPs = true

setupVolumes = () ->
  $('#ebs-volumes').jqGrid
    datatype: 'local'
    height: 200
    width: 1200
    ondblClickRow: (rowid, rowIndex, colIndex, e) ->
      showVolumesDialog rowid
    colNames: [
      'Volume ID'
      'Size (GB)'
      'Snapshot ID'
      'Availability Zone'
      'Status'
      'Creation time'
    ]
    colModel: [
      {name:'volume_id',index:'volume_id',width:200}
      {name:'size',index:'size',width:200, align: 'right', sorttype: 'int'}
      {name:'snapshot_id',index:'snapshot_id',width:200}
      {name:'az',index:'az',width:200}
      {name:'status',index:'status',width:200}
      {name:'creation',index:'creation',width:200}
    ]
    multiselect: true
    caption: "Volumes"

showVolumes = (data) ->
  if not showingVolumes
    $("#ebs-volumes").jqGrid('addRowData',i+1,dataPoint) for dataPoint, i in data
    volumeData = data
  showingVolumes = true

setupSnapshots = () ->
  $('#ebs-snapshots').jqGrid
    datatype: 'local'
    height: 200
    width: 1200
    colNames: [
      'Snapshot ID'
      'Volume ID'
      'Status'
      'Start Time'
      'Progress'
      'Owner'
      'Size'
      'Description'
    ]
    colModel: [
      {name:'snapshot_id',index:'snapshot_id',width:200}
      {name:'volume_id',index:'volume_id',width:200}
      {name:'status',index:'status',width:200}
      {name:'start_time',index:'start_time',width:200}
      {name:'progress',index:'progress',width:200}
      {name:'owner',index:'owner',width:200}
      {name:'size',index:'size',width:200, sorttype: 'int'}
      {name:'description',index:'description',width:200}
    ]
    multiselect: false
    caption: "Snapshots"

showSnapshots = (data) ->
  if not showingSnapshots
    $('#ebs-snapshots').jqGrid('addRowData',i+1,dataPoint) for dataPoint, i in data
  showingSnapshots = true

setupZones = () ->
  $('#availability-zones').jqGrid
    datatype: 'local'
    height: 200
    width: 1200
    colNames: [
      'Zone Name'
      'Zone State'
      'Region Name'
      'Messages'
    ],
    colModel: [
      {name:'zoneName',index:'zoneName',width:200},
      {name:'zoneState',index:'zoneState',width:200},
      {name:'regionName',index:'regionName',width:200},
      {name:'messages',index:'messages',width:200}
    ]
    multiselect: true
    caption: "Availability Zones"

showZones = (data) ->
  if not showingZones
    $("#availability-zones").jqGrid('addRowData',i+1,dataPoint) for dataPoint,i in data
  showingZones = true

handleFailure = () ->
  alert 'failure'

openDialog = (callback) -> 
  $("#credentials-dialog").dialog "option", "buttons", { 
                  "Save": () ->
                    accessKey = access.value
                    secretKey = secret.value
                    $(this).dialog "close" 
                    localStorage.setItem "accessCode", accessKey
                    localStorage.setItem "secretKey", secretKey
                    callback accessKey, secretKey
                  }
  $("#credentials-dialog").dialog 'open'

$(document).ready () ->
  $("#instances-show").hide()
  $("#images-show").hide()
  $("input:submit", ".imageTagButton").button()
  $("input:submit", ".imageRunButton").button()
  setupInstances()
  setupImages()
  setupKeyPairs()
  setupSecurityGroups()
  setupElasticIPs()
  setupVolumes()
  setupSnapshots()
  setupZones()

  ###
  # Test of getting the clients ip
  ipCallback = (data, textStatus, jqXHR) ->
    console.log(data)

  callConfig =
    type: "GET"
    url: "http://jsonip.appspot.com/"
    success: ipCallback
    failure: handleFailure
    dataType: 'jsonp'

  $.ajax callConfig
  ###

  request = {}
  request.min = 1
  request.max = 1
  request.ami = 'ami-a8e21cc1'
  request.type = 'm1.large'
  request.sec_groups = ['GENSENT_freedonia_EBS']
  #runInstances request, alert, handleFailure

  $("#tabs").tabs
    selected: 0
    show: (e, ui) ->
      switch ui.index
        when 0 then getInstances showInstances, handleFailure
        when 1
          $("#instances-show").show()
          getImages showImages, handleFailure
        when 2 then getKeyPairs showKeyPairs, handleFailure
        when 3 then getSecurityGroups showSecurityGroups, handleFailure
        when 4 then getElasticIPs showElasticIPs, handleFailure
        when 5 
          getVolumes showVolumes, handleFailure
          getSnapshots showSnapshots, handleFailure
        when 7 then getAvailabilityZones showZones, handleFailure
  saveButton = 
    text: "Save"
    click: -> 
      alert "Clicked"
  $("#credentials-dialog").dialog 
    autoOpen: false
    modal: true
    width: 500
    buttons: [ saveButton ]
    close: () ->
      $('#access').val ""
      $('#secret').val ""

  $("#image-dialog").dialog
    autoOpen: false
    modal: true
    width: 600
    open: () ->
      $('#image-accordion').accordion()
  $("#instance-dialog").dialog
    autoOpen: false
    modal: true
    width: 1000
    open: () ->
      $('#instance-accordion').accordion
        autoHeight: false
        navigation: true
  $("#volume-dialog").dialog
    autoOpen: false
    modal: true
    width: 1000
    open: () ->
      $('#volume-accordion').accordion
        autoHeight: false
        navigation: true
