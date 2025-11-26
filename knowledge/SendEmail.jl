import Pkg
Pkg.add(["SMTPClient"])
using SMTPClient

"""`send_email(["<to@email.org>"], "body", "message")`"""
@api function send_email(to::Vector{String}, subject::String, message::String)
  from = "<email@1m1.io>"
  body = get_body(to, from, subject, message)
  # body = get_body(to, from, subject, message; cc, replyto)
  opt = SendOptions(
    isSSL=true,
    username="1@1m1.io",
    passwd="zudy uxqf rxhj qicr")
  url = "smtps://smtp.gmail.com:465"
  send(url, to, from, body, opt)
end
