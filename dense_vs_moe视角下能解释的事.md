# dense vs MoE 视角下，能解释哪些事

更新时间：2026-03-11

## dense 和 MoE 是什么

`dense` 指“稠密模型”，`MoE` 则是 `Mixture of Experts`，即“混合专家模型”，属于一种典型的稀疏模型。

所谓“稠密”，是指模型在生成时，主干网络的参数基本都会参与计算；所谓“稀疏”，则是模型虽然总参数很多，但每次只激活其中一部分。

打个比方，dense 像一个全科超级天才，无论写代码、做翻译还是写文章，都由同一个大脑亲自处理；MoE 则更像一支各有所长的专家小队，遇到不同问题时，系统会挑出最合适的几位上场。

dense 的好处是结构直接、训练路径统一、能力分布通常更平滑；代价则是参数一大，训练和推理成本都会跟着一起上去。MoE 的优势是更容易在可接受的推理成本下继续扩容；代价则是会额外引入路由器训练、load balancing、专家利用不均、专家塌缩、跨卡通信等复杂问题。

## 为什么 GPT 和 Claude 能打得有来有回，但 Claude 明显更贵

在编码场景里，`Claude Opus 4.6` 和 `GPT-5.3-Codex / GPT-5.4` 的基准测试和社区评价往往是互有胜负，但价格差依然很明显。

从 API 价格看，Claude 明显更贵。

以 2026 年 3 月的公开价格为例，`GPT-5.3-Codex` 的价格是输入 `1.75 美元/百万 token`、输出 `14 美元/百万 token`，`GPT-5.4` 是输入 `2.50 美元/百万 token`、输出 `15 美元/百万 token`，而 `Claude Opus 4.6` 则是输入 `5 美元/百万 token`、输出 `25 美元/百万 token`。

在订阅层面，两家虽然都有 `20 美元/月` 档位，但实际使用体验并不对等，社区普遍反馈 GPT 的可用额度明显多于 Claude。

也就是说，无论按 API 单价还是按订阅后的有效额度看，Claude 的实际使用成本都更高。

价格差的背后，往往是推理成本差；而推理成本差，又常常和模型的架构路线有关。

Claude 常被外界理解为更偏 dense 的一边，不只是因为不少二手资料会直接把它归进 dense transformer，也因为 Anthropic 长期对外展示的，是 Haiku、Sonnet、Opus 这样一组按速度、能力和成本分层的模型家族，而不是带有明确专家数、active parameters、路由机制等信息的 MoE 叙事。

相对地，GPT 从 4 代开始就被分析圈和技术社区广泛推断走向 MoE 路线，OpenAI 后来公开发布的 `gpt-oss` 也明确采用了 Mixture-of-Experts。

这么看下来，Claude 更像高计算、均衡型的大脑，GPT 则更像更早拥抱稀疏化路线的模型家族。

这也解释了 Claude 为什么口碑一直不错。它的特点往往不是某一项能力特别偏科，而是整体都能打：代码、写作、分析、工具使用，几乎样样都精通。问题在于，这种全面不是白来的，账单会提醒你它到底有多全面。

所以，GPT 更便宜、Claude 更贵，但两者在编码上依然难分高下，放在 dense vs MoE 这个框架下看，其实很好理解。GPT 更像是在用稀疏化把“强”做得更便宜，Claude 则更像是在用更高的计算成本去换一个更均衡的全能表现。

## 为什么 Qwen 小模型常常惊艳，而旗舰却不总是脱颖而出

从Qwen3.5 这代模型的结构来看很清楚：0.8B、2B、4B、9B、27B 是 dense，35B-A3B、122B-A10B、397B-A17B 则是 MoE。规律显而易见，小模型走 dense，大模型走 MoE。与此同时，同期的 GLM-5、Kimi K2.5、MiniMax M2.5，都是 MoE 的大模型旗舰。

问题的关键在于，同样是开源模型，几 B、几十 B 的小模型和几百 B 的旗舰模型，其实是两个赛道。前者首先要解决的，是能不能在消费级硬件上装得下、跑得动，本地部署时的显存（或苹果的统一内存）容量的门槛至关重要；后者则几乎天然是专用计算卡和云端服务的赛道，普通用户通常只能通过网页和 API 接触。

模型整体尺寸决定显存占用，而激活尺寸决定推理开销和速度。

对小模型来说，首要问题并非推理时的算力消耗，而是模型能不能在有限而昂贵的显存里装得下，跑得动。在本地部署场景中，如果总参数规模相近，dense 往往比总量大但 active 很小的 MoE 更划算，因为前者更容易把有限的参数预算直接转化为能力。在这种约束下，小模型普遍走 dense 路线，其实是很自然的结果。

而到了旗舰档，问题就完全变了，单位token的推理成本和定价决定了厂商的毛利率，推理速度相当程度上影响用户体验，MoE 显然是更经济和实际的选择。

这就是为什么，小模型通常选择 dense，大模型通常选择 MoE（除了Claude这个怪胎）。

尽管dense和MoE模型有许多通用之处，但训练和部署MoE也会多出一整套 dense 没有的难题，包括路由器训练稳定性、load balancing、专家塌缩、专家利用不均等等。Qwen 同时维护 dense 小模型和 MoE 旗舰，难免会面对更高的资源压力和工程复杂度。这或许也解释了为什么 Qwen 的小模型常常惊艳，而旗舰虽然依然很强，却往往略逊于更专注押注 MoE 旗舰路线的 GLM、Kimi 和 MiniMax 。

## dense vs MoE 真正解释了什么

把这些现象放在一起看，dense vs MoE 的差别就不只是技术实现细节，而是会直接投射到价格、部署门槛、社区口碑和旗舰叙事上。

`dense` 更容易带来均衡、直接、手感顺滑的能力体验，但扩到旗舰后，训练和推理成本都更重。

`MoE` 更适合在不让单次推理成本同步爆炸的前提下继续把总参数堆大，因此特别适合旗舰和大规模 API 服务；可与此同时，它也把系统复杂度、研发难度和工程门槛一起抬高了。

于是就会出现这些很常见的现象：

- 有的模型综合手感很好，但贵
- 有的模型榜单很强，但本地和社区口碑未必最强
- 小模型家族完整的团队，更容易在社区拿到长期口碑
- 把旗舰 MoE 做得又强又便宜的团队，更容易拿到“冠军相”

如果把这篇文章压成一句话，那就是：`dense vs MoE` 的差别，不只是技术路线之争，它会直接影响人们对一个模型“顺不顺手”“值不值”“为什么会这样定价”的直觉判断。

## 参考链接

- OpenAI API 定价：[openai.com/api/pricing](https://openai.com/api/pricing/)
- GPT-5.3-Codex 模型页：[developers.openai.com/api/docs/models/gpt-5.3-codex](https://developers.openai.com/api/docs/models/gpt-5.3-codex)
- ChatGPT Plus 定价：[help.openai.com/en/articles/6950777-what-is-chatgpt-plus](https://help.openai.com/en/articles/6950777-what-is-chatgpt-plus)
- Anthropic 模型总览：[platform.claude.com/docs/en/about-claude/models/overview](https://platform.claude.com/docs/en/about-claude/models/overview)
- Anthropic 定价：[docs.anthropic.com/en/docs/about-claude/pricing](https://docs.anthropic.com/en/docs/about-claude/pricing)
- Claude Pro 定价：[support.anthropic.com/en/articles/8325610-how-much-does-claude-pro-cost](https://support.anthropic.com/en/articles/8325610-how-much-does-claude-pro-cost)
- OpenAI `gpt-oss` 架构说明：[openai.com/index/introducing-gpt-oss](https://openai.com/index/introducing-gpt-oss)
- OpenAI 使用规模披露（2025-12-08）：[openai.com/index/the-state-of-enterprise-ai-2025-report](https://openai.com/index/the-state-of-enterprise-ai-2025-report/)
- OpenAI 印度周活披露（2026-02-18）：[openai.com/openai-for-india](https://openai.com/openai-for-india)
- Qwen3.5-0.8B：[huggingface.co/Qwen/Qwen3.5-0.8B](https://huggingface.co/Qwen/Qwen3.5-0.8B)
- Qwen3.5-2B：[huggingface.co/Qwen/Qwen3.5-2B](https://huggingface.co/Qwen/Qwen3.5-2B)
- Qwen3.5-4B：[huggingface.co/Qwen/Qwen3.5-4B](https://huggingface.co/Qwen/Qwen3.5-4B)
- Qwen3.5-9B：[huggingface.co/Qwen/Qwen3.5-9B](https://huggingface.co/Qwen/Qwen3.5-9B)
- Qwen3.5-27B：[huggingface.co/Qwen/Qwen3.5-27B](https://huggingface.co/Qwen/Qwen3.5-27B)
- Qwen3.5-35B-A3B：[huggingface.co/Qwen/Qwen3.5-35B-A3B](https://huggingface.co/Qwen/Qwen3.5-35B-A3B)
- Qwen3.5-122B-A10B：[huggingface.co/Qwen/Qwen3.5-122B-A10B](https://huggingface.co/Qwen/Qwen3.5-122B-A10B)
- Qwen3.5-397B-A17B：[huggingface.co/Qwen/Qwen3.5-397B-A17B](https://huggingface.co/Qwen/Qwen3.5-397B-A17B)
- GLM-5 发布说明：[docs.z.ai/release-notes/new-released](https://docs.z.ai/release-notes/new-released)
- Kimi K2.5 模型卡：[huggingface.co/moonshotai/Kimi-K2.5](https://huggingface.co/moonshotai/Kimi-K2.5)
- MiniMax-M2 模型页：[huggingface.co/MiniMaxAI/MiniMax-M2](https://huggingface.co/MiniMaxAI/MiniMax-M2)
- MiniMax M2.5 官方定价：[platform.minimax.io/docs/guides/pricing-paygo](https://platform.minimax.io/docs/guides/pricing-paygo)
- Artificial Analysis：`GLM-5`、`Kimi K2.5`、`Qwen3.5-397B-A17B`、`MiniMax-M2.5`
  - [artificialanalysis.ai/models/glm-5](https://artificialanalysis.ai/models/glm-5/)
  - [artificialanalysis.ai/models/kimi-k2-5](https://artificialanalysis.ai/models/kimi-k2-5)
  - [artificialanalysis.ai/models/qwen3-5-397b-a17b](https://artificialanalysis.ai/models/qwen3-5-397b-a17b)
  - [artificialanalysis.ai/models/minimax-m2-5](https://artificialanalysis.ai/models/minimax-m2-5)








