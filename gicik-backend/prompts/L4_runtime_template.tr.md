<user_profile>
arketip: {{ archetype_primary }} ({{ archetype_secondary }} hint'i)
direktlik: {{ directness }} | mizah: {{ humor.primary_type }} ({{ humor.intensity }})
slang: {{ slang_level }} | dil: {{ language.primary }} (eng_mix={{ english_mix_ratio }})
bağlam: en çok {{ top_context }}
red lines: {{ boundaries.avoid | join(", ") }}
</user_profile>

<conversation_analysis>
{{ stage1_parse_json }}
</conversation_analysis>

<user_intent>
mode: {{ mode }}
selected_tone: {{ tone }}
</user_intent>
