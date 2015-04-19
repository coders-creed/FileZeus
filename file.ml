open Printf

let read_file fname =
  let channel = open_in fname in
  let len = in_channel_length channel in
  let str = String.create len in
  really_input channel str 0 len;
  close_in channel;
  
  (str)
;;

let write_file fname content =
  let channel = open_out fname in
  fprintf channel "%s" content;
  close_out channel;
;;