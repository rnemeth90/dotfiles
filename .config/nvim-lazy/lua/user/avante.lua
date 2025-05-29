local status_ok, avante = pcall(require, "avante")
if not status_ok then
  return
end

avante.setup{
  opts = {
    -- add any opts here
    -- for example
    provider = "openai",
    openai = {
      endpoint = "https://api.openai.com/v1",
      model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
      timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
      temperature = 0,
      max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
      -- reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
    },
  },
  web_search_engine = {
    provider = "google", -- tavily, serpapi, searchapi, google or kagi
  }
}
