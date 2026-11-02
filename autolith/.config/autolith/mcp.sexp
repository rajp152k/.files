(:version 1
 :servers
 ((:name "paperclip"
    :transport (:type :stdio
                :command "/bin/sh"
                :arguments ("-c"
                            "cd \"$HOME/.local/share/autolith/integrations/paperclip\" && exec ./launch"))
   :required-p nil
   :startup-timeout-seconds 30
   :tool-timeout-seconds 60
   :approval :allow)))
