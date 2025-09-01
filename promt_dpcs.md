<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# дай список документаций промтинга, советов к промтам, лучших практик с работой с новой open source моделью от openai gtp oss 120B.

Кратко: ниже собраны официальные документы, руководства по промптингу, практические советы и шаблоны для продуктивной работы с новой открытой моделью OpenAI **gpt-oss-120B** с учётом её особенностей (формат **harmony**, уровни reasoning, CoT, инструментальный вызов и Structured Outputs). Эти материалы охватывают как архитектурные и лицензионные аспекты, так и прикладные рекомендации по формулировке промптов и интеграции в агентные пайплайны.[^1][^2][^3]

## Официальные документы

- Страница модели на OpenAI Platform: характеристики gpt-oss-120b, контекст 131 072 токенов, поддержка streaming, function calling и Structured Outputs, а также сведения о полном доступе к Chain‑of‑Thought для отладки.[^1]
- Анонс gpt-oss: Apache 2.0 лицензия, близость по качеству к o4‑mini, совместимость с Responses API, поддержка инструментов (веб‑поиск, Python), настройка уровня рассуждений и открытый harmony‑renderer для корректного формата диалога.[^2]
- Model Card: рекомендации по безопасности и оценкам по Preparedness Framework, отличия рисков для открытых весов и необходимость дополнительных защит на стороне системы при продакшн‑развёртывании.[^3]


## Промптинг: что важно учитывать

- Использовать формат **harmony**: модели пост‑тренированы именно на harmony; при работе через Transformers чат‑шаблон применяет его автоматически, иначе следует использовать harmony‑renderer или вручную формировать шаблон.[^4][^2]
- Уровни рассуждений: задавать «Reasoning: low/medium/high» в system‑сообщении, балансируя скорость и глубину анализа под конкретную задачу.[^2][^4]
- Работа с **CoT**: полный CoT доступен для отладки, однако его не следует показывать конечным пользователям в финальном ответе приложения.[^1][^2]
- Инструменты и функции: описывать JSON‑схемы функций и явно разрешать вызовы; модели поддерживают function calling, веб‑поиск и выполнение Python в агентных сценариях.[^4][^2][^1]
- Структурированные ответы: задавать ожидаемую схему JSON и требовать строгого соответствия, опираясь на поддержку Structured Outputs.[^2][^1]
- Контекст и длина вывода: учитывать 128k контекст и целенаправленно ограничивать генерируемые токены в зависимости от задачи и SLA.[^1]
- Безопасность и иерархия инструкций: использовать системные инструкции, делегировать фильтры и валидации на уровне приложения, следовать рекомендациям Model Card и учитывать риск‑профиль открытых весов.[^3][^2]


## Готовые шаблоны промптов

- Скелет system‑сообщения для аналитических задач с высоким качеством рассуждений и скрытым CoT.[^4][^2]

```text
System:
- You are OpenAI gpt-oss-120b aligned to the OpenAI Model Spec.
- Reasoning: high
- Follow the instruction hierarchy; use hidden chain-of-thought to solve.
- Final output: Russian, concise, no CoT; if tools used, summarize results only.
- If a schema is provided, strictly adhere to it.
```

Ключевые элементы: явное указание уровня reasoning, запрет на показ CoT в финальном ответе и требование точного формата вывода под задачу.[^2][^4]

- Пример для инструментов и function calling (объявить функции и когда их вызывать).[^4][^1][^2]

```text
System:
- Tools available: { "web_search": { "params": {"query": "string"} }, "python": { "params": {"code": "string"} } }.
- Decide to call a tool only if it clearly improves accuracy or is required by the task.
- After tool calls, verify results and produce a short, sourced final answer (no CoT).
```

Такая формулировка улучшает выбор момента вызова инструмента и снижает «бесполезные» обращения, сохраняя контроль качества ответа.[^1][^2][^4]

- Пример для Structured Outputs (строгая JSON‑схема).[^2][^1]

```text
System:
- Output must be valid JSON matching this schema:
  {
    "type": "object",
    "properties": {
      "answer": {"type":"string"},
      "sources": {"type":"array","items":{"type":"string"}}
    },
    "required": ["answer","sources"],
    "additionalProperties": false
  }
- No extra text outside JSON.
```

Чёткая схема повышает детерминизм и упрощает валидацию на стороне приложения и последующую обработку.[^1][^2]

## Практические гайды и экосистема

- Hugging Face: модельная страница с инструкциями для Transformers/vLLM/Ollama, автоприменением harmony в чат‑шаблоне и управлением уровнем «Reasoning: low/medium/high».[^4]
- Groq Docs: краткое руководство и код‑сниппеты для вызова модели у провайдера с высокой пропускной способностью.[^5]
- Together AI: страница модели с описанием возможностей и контекста использования через провайдера (OpenAI‑совместимый доступ).[^6]
- Northflank: развёртывание gpt‑oss‑120B «в один клик» с vLLM и Open WebUI для быстрых экспериментов с промптами и параметрами генерации.[^7]
- OpenRouter: агрегатор провайдеров и метаданных по доступности gpt‑oss‑120B, полезен для сравнений в реальных условиях.[^8]
- Русскоязычный обзор на Хабре: технические особенности, MoE‑архитектура, 128k контекст, квантование MXFP4 и ориентиры по применению в проде.[^9]


## Чек‑лист лучших практик

- Убедиться, что применяется harmony‑шаблон; без него ответы могут деградировать по формату и качеству.[^4]
- Задать уровень рассуждений в system‑сообщении под SLA задачи; для интерактива — low/medium, для сложного анализа — high.[^2][^4]
- Скрывать CoT и выдавать только финальный ответ; использовать CoT исключительно для отладки и контроля качества.[^2]
- Для инструментов и JSON‑вывода заранее описывать схемы/контракты и жёстко им следовать (Structured Outputs, function calling).[^1][^2]
- Реализовать валидацию и фильтрацию на уровне приложения, учитывая модельную карту и оценку рисков открытых весов.[^3]

Если нужны дополнительные примеры под специфичный домен (код, медицина, правовой анализ) или помощь с миграцией промптов под harmony и уровни reasoning, можно опираться на официальные гайды и примеры в анонсе и модельной карточке, дополняя их практиками из экосистемных провайдеров.[^3][^4][^2]
<span style="display:none">[^10][^11][^12]</span>

<div style="text-align: center">⁂</div>

[^1]: https://platform.openai.com/docs/models/gpt-oss-120b

[^2]: https://openai.com/index/introducing-gpt-oss/

[^3]: https://openai.com/index/gpt-oss-model-card/

[^4]: https://huggingface.co/openai/gpt-oss-120b

[^5]: https://console.groq.com/docs/model/openai/gpt-oss-120b

[^6]: https://www.together.ai/models/gpt-oss-120b

[^7]: https://northflank.com/blog/self-host-openai-gpt-oss-120b-open-source-chatgpt

[^8]: https://openrouter.ai/openai/gpt-oss-120b

[^9]: https://habr.com/ru/companies/selectel/articles/934902/

[^10]: https://blog.laozhang.ai/ai-development/openai-oss-models-guide-2025/

[^11]: https://www.youtube.com/watch?v=ZhA9QDt12Q8

[^12]: https://docs.ionos.com/cloud/ai/ai-model-hub/models/openai-gpt-oss-120b

