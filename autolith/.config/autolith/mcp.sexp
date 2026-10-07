(:version 1
 :servers
 ((:name "arxiv"
   :transport
   (:type :stdio
    :command "/bin/sh"
    :arguments ("-c" "exec \"$HOME/.local/share/arxiv-mcp/node_modules/node/bin/node\" \"$HOME/.local/share/arxiv-mcp/node_modules/@cyanheads/arxiv-mcp-server/dist/index.js\"")
    :directory :workspace)
   :required-p nil
   :startup-timeout-seconds 30
   :tool-timeout-seconds 90
   :approval :read-only
   :trusted-read-only-tools
   ("arxiv_search" "arxiv_get_metadata" "arxiv_list_categories" "arxiv_read_paper"))))
