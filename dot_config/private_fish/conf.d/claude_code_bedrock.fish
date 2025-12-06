# Claude Code + Amazon Bedrock configuration (Option D: API key auth)
# Fill in placeholders or update the model/region values to match your account.

# Enable Bedrock integration for Claude Code
set -gx CLAUDE_CODE_USE_BEDROCK 1

# Required: primary region for API calls (must be explicitly set)
set -gx AWS_REGION us-east-1 # TODO: change if your Bedrock access is in another region

# Optional: override the fast model region if different
if not set -q ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION
    set -gx ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION us-west-2
end

# Bedrock API key authentication (Option D)
# Store your key in the macOS keychain with: security add-generic-password -a $USER -s "aws_bedrock_api_key" -w '<token>'
# Then uncomment the line below to automatically export it for Claude Code.
set -gx AWS_BEARER_TOKEN_BEDROCK "***REDACTED***"

# Claude Code default models (override if you use different inference profiles)
# set -gx ANTHROPIC_MODEL "global.anthropic.claude-sonnet-4-5-20250929-v1:0"
set -gx ANTHROPIC_SMALL_FAST_MODEL "us.anthropic.claude-haiku-4-5-20251001-v1:0"
# Example: pin Haiku version explicitly if Bedrock doesn't auto-upgrade
set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "us.anthropic.claude-haiku-4-5-20251001-v1:0"

# Output token settings recommended for Bedrock workloads
set -gx CLAUDE_CODE_MAX_OUTPUT_TOKENS 4096
set -gx MAX_THINKING_TOKENS 1024

# Optional flags you can toggle if you need to disable prompt caching or specify inference profile ARNs
# set -gx DISABLE_PROMPT_CACHING 1
# set -gx ANTHROPIC_MODEL "arn:aws:bedrock:REGION:ACCOUNT:application-inference-profile/PROFILE_ID"
