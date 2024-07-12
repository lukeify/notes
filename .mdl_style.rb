all

# Line length is disabled as I write according to https://sembr.org
exclude_rule 'MD013'

# Allow trailing question marks in headers
rule 'MD026', :punctuation => '.,;:!'

# Prefer correctly-ordered numbered lists for reading.
rule 'MD029', :style => :ordered

# Allow span elements within Markdown. We use these to mark words and phrases for no-spelling via the span[data-nospell]
# selector.
rule 'MD033', :allowed_elements => 'span'

# Exclude problematic/buggy rules
# See https://github.com/markdownlint/markdownlint/issues/489 for more details
exclude_rule 'MD055'
exclude_rule 'MD056'
exclude_rule 'MD057'
