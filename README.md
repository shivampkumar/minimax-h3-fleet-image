# MiniMax H3 Fleet image

Reproducible runtime image for Fleet's KubeRay jobs. It pins vLLM 0.29,
vLLM-Omni commit `01a2f93256975c7ff9565c5414b0fe0225bc4765`, Ray 2.56.1, and
FastVideo Kernel 0.3.5. The Docker build includes command and package smoke
checks so incompatible images fail before a GPU run is submitted.
