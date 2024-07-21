all

# Prefer pound keys to start headers
rule 'MD003', :style => :atx

# Prefer dashes for unordered lists
rule 'MD004', :style => :dash

# Prefer four spaces for unordered list indentation
rule 'MD007', :indent => 4

# Line length is disabled as I write according to https://sembr.org
exclude_rule 'MD013'

# Would prefer to allow headers to have the same content in different nesting contexts, but unfortunately even with
# `allow_different_nesting` set, this does not consider parent-siblings as "different", so this rule must be disabled for now.
# rule 'MD024', :allow_different_nesting => true
exclude_rule 'MD024'

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
