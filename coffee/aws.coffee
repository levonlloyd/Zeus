###
#
# Collection of routines for interacting with AWS
#
###

API_VERSION = "2009-11-30"

###
# Get information on the availability zones.  Calls success with an array of 
# objects on success
###
getAvailabilityZones = (handleSuccess, handleFailure) ->
  zoneSuccess = (data, status, jqXHR) ->
    zones = []
    $(data).find('item').each ->
      zone = {}
      zone.zoneName = $(this).find('zoneName').text()
      zone.zoneState = $(this).find('zoneState').text()
      zone.regionName = $(this).find('regionName').text()
      messageSet = []
      $(this).find('messageSet').each ->
        messageSet.push $(this).text()
      zone.messages = messageSet
      zones.push zone
    handleSuccess zones

  credentialsCallback = (accessCode, secretKey) ->
    queryEC2 "DescribeAvailabilityZones", "", accessCode, secretKey, zoneSuccess, handleFailure
  getAWSCreds credentialsCallback

getElasticIPs = (handleSuccess, handleFailure) ->
  elasticIPSuccess = (data, status, jqXHR) ->
    ips = []
    $(data).find('item').each ->
      ip = {}
      ip.ip = $(this).find('publicIp').text()
      ip.instance = $(this).find('instanceId').text()
      ips.push ip
    handleSuccess ips

  credentialsCallback = (accessCode, secretKey) ->
    queryEC2 "DescribeAddresses", [], accessCode, secretKey, elasticIPSuccess, handleFailure
  getAWSCreds credentialsCallback

getInstances = (handleSuccess, handleFailure) ->
  instanceSuccess = (data, status, jqXHR) ->
    instances = []
    $(data).find('instancesSet').children().each ->
      instance = {}
      instance.instanceId = $(this).find('instanceId').text()
      instance.secGroup = $(this).find('groupSet').text()
      instance.az = $(this).find('placement').text()
      instance.dnsName = $(this).find('dnsName').text()
      instance.ami = $(this).find('imageId').text()
      instance.architecture = $(this).find('architecture').text()
      instance.state = $(this).find('state').text()
      instance.launchTime = $(this).find('launchTime').text()
      instance.privateDnsName = $(this).find('privateDnsName').text()
      instance.platform = $(this).find('platform').text()
      instance.keyName = $(this).find('keyName').text()
      instance.rootDeviceType =  $(this).find('rootDeviceType').text()
      instances.push instance
    handleSuccess instances

  params = []

  credentialsCallback = (accessCode, secretKey) ->
    queryEC2 "DescribeInstances", params, accessCode, secretKey, instanceSuccess, handleFailure
  getAWSCreds credentialsCallback

###
# Get information on the images that are available
# TODO: Add all fields of result
###
getImages = (handleSuccess, handleFailure) ->
  imageSuccess = (data, status, jqXHR) ->
    images = []
    $(data).find('imagesSet').children().each ->
      image = {}
      image.imageId = $(this).find('imageId').text()
      image.imageLocation = $(this).find('imageLocation').text()
      image.imageState = $(this).find('imageState').text()
      image.imageOwnerId = $(this).find('imageOwnerId').text()
      image.isPublic = $(this).find('isPublic').text()
      image.architecture = $(this).find('architecture').text()
      image.imageType = $(this).find('imageType').text()
      image.kernelId = $(this).find('kernelId').text()
      image.ramDiskId = $(this).find('ramdiskId').text()
      image.name = $(this).find('name').text()
      image.description = $(this).find('description').text()
      image.rootDeviceType =  $(this).find('rootDeviceType').text()
      image.tags = []
      images.push image
    handleSuccess images

  params = []
  params.push new Array("Owner.1", "self")

  credentialsCallback = (accessCode, secretKey) ->
    queryEC2 "DescribeImages", params, accessCode, secretKey, imageSuccess, handleFailure
  getAWSCreds credentialsCallback

###
# Get information on the key pairs associated with the account
###  
getKeyPairs = (handleSuccess, handleFailure) ->
  keyPairSuccess = (data, status, jqXHR) ->
    keyPairs = []
    $(data).find('item').each ->
      keyPair = {}
      keyPair.keyName = $(this).find('keyName').text()
      keyPair.keyFingerprint =  $(this).find('keyFingerprint').text()
      keyPairs.push keyPair
    handleSuccess keyPairs

  credentialsCallback = (accessCode, secretKey) ->
    queryEC2 "DescribeKeyPairs", "", accessCode, secretKey, keyPairSuccess, handleFailure
  getAWSCreds credentialsCallback

getConsoleOutput = (instance, handleSuccess, handleFailure) ->
  consoleOutputSuccess = (data, status, jqXHR) ->
    content = $(data).find('output').text()
    content = content.replace(/\s+/g, "")
    content = atob(content)
    handleSuccess(content)

  params = []
  params.push new Array("InstanceId", instance)

  credentialsCallback = (accessCode, secretKey) ->
    queryEC2 "GetConsoleOutput", params, accessCode, secretKey, consoleOutputSuccess, handleFailure
  getAWSCreds credentialsCallback

# Fetch AWS credentials from local storage.  If not present, prompt user
# call callback with keys when you have them
getAWSCreds = (callback) ->
  accessCode = localStorage.getItem "accessCode"
  secretKey = localStorage.getItem "secretKey"
  if accessCode? and secretKey?
    callback accessCode, secretKey
  else
    openDialog callback
    
addZero = (vNumber) ->
  prefix = if vNumber < 10 then "0" else ""
  prefix + vNumber

sigParamCmp = (x,y) ->
  if x[0].toLowerCase() < y[0].toLowerCase()
    -1
  else if x[0].toLowerCase() > y[0].toLowerCase()
    1
  else
    0

# Internal routine to format a date properly for the AWS signature
formatDate = (vDate, vFormat) ->
  vDay = addZero vDate.getUTCDate()
  vMonth = addZero vDate.getUTCMonth()+1
  vYearLong = addZero vDate.getUTCFullYear()
  vYearShort = addZero vDate.getUTCFullYear().toString().substring(3,4)
  vYear = if vFormat.indexOf "yyyy" > -1 
            vYearLong
          else 
            vYearShort
  vHour = addZero vDate.getUTCHours()
  vMinute = addZero vDate.getUTCMinutes()
  vSecond = addZero vDate.getUTCSeconds()
  vDateString = vFormat.replace(/dd/g, vDay)
  vDateString = vDateString.replace(/MM/g, vMonth)
  vDateString = vDateString.replace(/y{1,4}/g,vYear)
  vDateString = vDateString.replace(/hh/g, vHour)
  vDateString = vDateString.replace(/mm/g, vMinute)
  vDateString.replace(/ss/g, vSecond)

# Internal routine to call AWS.  Calls handleSuccess on Success and handleFailure on failure        
queryEC2 = (action, params, accessCode, secretKey, handleSuccess, handleFailure) ->
  curTime = new Date()
  formattedTime = formatDate curTime, "yyyy-MM-ddThh:mm:ssZ"
  sigValues = []
  sigValues.push new Array("Action", action)
  sigValues.push new Array("AWSAccessKeyId", accessCode)
  sigValues.push new Array("SignatureVersion", "1")
  sigValues.push new Array("Version", API_VERSION)
  sigValues.push new Array("Timestamp", formattedTime)

  sigValues.push param for param in params

  sigValues.sort(sigParamCmp)

  sigStr = ""
  queryParamsList = []
  for sigValue in sigValues
    do(sigValue) ->
      sigStr += sigValue[0] + sigValue[1]
      queryParamsList.push sigValue[0] + "=" + encodeURIComponent sigValue[1]

  queryParams = queryParamsList.join("&")
  sig = Crypto.util.bytesToBase64(Crypto.HMAC(Crypto.SHA1, sigStr, secretKey, {asBytes: true}));
  queryParams += "&Signature=" + encodeURIComponent sig

  callConfig =
    type: "POST"
    url: "https://ec2.amazonaws.com/"
    data: queryParams
    success: handleSuccess
    failure: handleFailure

  $.ajax callConfig
