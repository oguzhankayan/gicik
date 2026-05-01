<user_profile>
arketip: {{ archetype_primary }} ({{ archetype_secondary }} hint'i)
direktlik: {{ directness }} | mizah: {{ humor.primary_type }} ({{ humor.intensity }})
slang: {{ slang_level }} | dil: {{ language.primary }} (eng_mix={{ english_mix_ratio }})
demografi: {{ gender }}, {{ age_bracket }} | niyet: {{ intent }}
bağlam: en çok {{ top_context }}
red lines: {{ boundaries.avoid }}
</user_profile>
{{ user_voice_block }}
<conversation_analysis>
{{ stage1_parse_json }}
</conversation_analysis>
{{ extra_context_block }}
<user_intent>
mode: {{ mode }}
selected_tone: {{ tone }}
</user_intent>
