-- Configure yaml-language-server
return {
  settings = {
    yaml = {
      schemas = {
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0-standalone-strict/all.json"] =
        "/*.k8s.yaml",
      },
    },
  },
}
