require('source-map-support').install()

# requirements
os = require 'os'

# ignoring growl if user is under win32 (otherwise it'd break toaster)
growl = if os.platform() == 'win32' then null else require 'growl'

# ICONS 
icon_warn = __dirname + '/../images/warning.png'
icon_error = __dirname + '/../images/error.png'



# LOGGING METHODS
exports.log = ( msg, send_to_growl = false ) ->
  msg = "#{msg.white}"
  console.log msg
  return msg

exports.debug = ( msg, send_to_growl = false ) ->
  msg = "#{'DEBUG'.bold} #{msg}".magenta
  console.debug msg
  return msg

exports.error = ( msg, send_to_growl = true, file = null ) ->
  msg = "#{'ERROR'.bold} #{msg}".red
  console.error msg

  if send_to_growl && growl?

    # remove all colors
    msg = msg.replace /\[\d{2}m/g, ""

    # replaces all styles with _%string-here%_
    msg = msg.replace /(\[\dm)([^\s]+)/ig, "<$2>$3"

    # queue for growl
    queue_msg
      msg: msg
      opts:
        title: 'Coffee Toaster'
        image: icon_error
  
  return msg

exports.warn = ( msg, send_to_growl = true ) ->
  msg = "#{'WARNING'.bold} #{msg}".yellow
  console.warn msg

  if send_to_growl && growl?

    # remove all colors
    msg = msg.replace /\[\d{2}m/g, ""

    # replaces all styles with _%string-here%_
    msg = msg.replace /(\[\dm)([^\s]+)/ig, "<$2>$3"

    # queue for growl
    queue_msg
      msg: msg
      opts:
        title: 'Coffee Toaster'
        image: icon_warn
  
  return msg



# GROWL QUEUE PRO

msgs = []
interval = null

start_worker = () ->
  unless interval?
    interval = setInterval process_msgs, 150
    process_msgs()

stop_worker = () ->
  if interval?
    clearInterval interval
    interval = null



queue_msg = (msg) ->
  msgs.push msg
  start_worker()

process_msgs = () ->
  if msgs.length
    msg = msgs.shift()
    growl.notify msg.msg, msg.opts
  else
    stop_worker()