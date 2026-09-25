Think of them as **different layers**:

```text
                    USER
                     │
                     │ API request
                     ▼
              ┌──────────────┐
              │    vLLM      │  ← Inference server
              │              │
              │ loads/runs   │
              │ the model     │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │    MODEL     │  ← Llama / Qwen / etc.
              │              │
              │ Neural       │
              │ network      │
              │ weights      │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │     GPU      │  ← Hardware
              │              │
              │ NVIDIA GPU   │
              └──────────────┘
```

But technically, **vLLM uses the GPU to execute the model**. So a better mental model is:

```text
User
  ↓
vLLM
  ↓
Model
  ↓
GPU computes the model
  ↓
Generated tokens
  ↓
User
```

### What each one is

| Component      | What it is                                   | Example                       |
| -------------- | -------------------------------------------- | ----------------------------- |
| **Model**      | The actual AI/LLM                            | Llama, Qwen                   |
| **vLLM**       | Software that serves the model               | vLLM server                   |
| **GPU**        | Hardware that performs the heavy computation | NVIDIA H100, A100, L40S       |
| **Kubernetes** | Manages the vLLM workloads                   | Schedules pods onto GPU nodes |

### In your Kubernetes environment

You could have:

```text
Kubernetes Cluster
│
├── CPU Node
│
└── GPU Node
      │
      ├── GPU 0
      └── GPU 1
            │
            └── vLLM Pod
                  │
                  └── Llama/Qwen Model
```

The important distinction is:

**Model ≠ vLLM ≠ GPU**

* **Model** = the AI brain/data/weights
* **vLLM** = the software serving that brain
* **GPU** = the hardware doing the computation
* **Kubernetes** = the platform managing where and how vLLM runs

And **TTFT** measures the time from the user's request until that setup produces the **first token**.
