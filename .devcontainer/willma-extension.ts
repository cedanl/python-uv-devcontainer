import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default async function (pi: ExtensionAPI) {
  const apiKey = process.env.WILLMA_API_KEY;
  const baseUrl = process.env.WILLMA_BASE_URL;
  if (!apiKey || !baseUrl) return;

  let models: any[] = [];
  try {
    const resp = await fetch(`${baseUrl}/sequences`, {
      headers: { "X-API-KEY": apiKey },
    });
    if (!resp.ok) return;
    const data = await resp.json();
    const list = Array.isArray(data) ? data : (data.data ?? []);
    models = list
      .filter((m: any) => m.sequence_type === "text")
      .map((m: any) => ({
        id: m.name,
        name: m.name,
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      }));
  } catch {
    return;
  }

  if (models.length === 0) return;

  pi.registerProvider("willma", {
    name: "SURF Willma AI-Hub",
    baseUrl,
    api: "openai-completions",
    apiKey: "WILLMA_API_KEY",
    headers: { "X-API-KEY": "WILLMA_API_KEY" },
    compat: { supportsDeveloperRole: false, supportsReasoningEffort: false },
    models,
  });
}
