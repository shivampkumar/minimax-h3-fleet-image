FROM docker.io/vllm/vllm-openai@sha256:082ca6f035279109041ffd3fe0695cb568b29bc580b35c4f297a66a08b216c1b

ARG VLLM_OMNI_COMMIT=01a2f93256975c7ff9565c5414b0fe0225bc4765

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ffmpeg git jq \
    && rm -rf /var/lib/apt/lists/*

# Fleet starts Ray before launching the submitted command. Keep vLLM 0.29,
# vLLM-Omni main, Ray, and FastH3's optional VSA kernel in one immutable image.
RUN uv pip install --system --no-cache-dir \
      "vllm-omni @ git+https://github.com/vllm-project/vllm-omni.git@${VLLM_OMNI_COMMIT}" \
      "ray[default]==2.56.1" \
      "fastvideo-kernel==0.3.5"

# Fail during image construction if the Fleet boot contract or serving stack
# is incomplete. The kernel check avoids importing CUDA code without a GPU.
RUN ray --version \
    && command -v vllm \
    && command -v hf \
    && command -v ffmpeg \
    && command -v ffprobe \
    && python3 - <<'PY'
import importlib.metadata
import importlib.util

assert importlib.metadata.version("vllm").startswith("0.29.")
assert importlib.metadata.version("vllm-omni").startswith("0.29.")
assert importlib.metadata.version("ray") == "2.56.1"
assert importlib.util.find_spec("fastvideo_kernel") is not None
print("H3 Fleet image smoke checks passed")
PY

ENTRYPOINT []
