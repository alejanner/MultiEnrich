# MultiEnrich

**MultiEnrich** is a notebook-first pipeline for **multi-omics enrichment analysis** on **directionally coherent genes**
(expression + promoter methylation), using a **pathway-first** strategy based on **GSEA leading-edge consensus**.

This repository was developed and tested on a real case study: **endocrine therapy resistance in breast cancer**, using
**tamoxifen-resistant cell lines** (e.g., MCF7 TamR, T47D TamR/TR1, BT474 TamR, ZR75-1 Tam2).

---

## Why MultiEnrich?

In endocrine-resistance models, signals are often **cell line–specific**: baseline identity can dominate both expression and methylation, making cross-model interpretation challenging. Looking at a single omics layer in isolation can therefore be noisy and misleading:

- **Differential expression** may highlight many genes that are not consistently altered across models, and results can be hard to translate into shared mechanisms.
- **Promoter methylation** changes are context-dependent and do not necessarily propagate to expression in a straightforward way.
- **Pathway analyses (e.g., GSEA)** can vary across runs and datasets.


MultiEnrich connects these layers by answering a concrete question:

> **Are directionally coherent genes (promoter methylation + expression) enriched in the pathways driving resistance?**

Key ideas:
- Use **leading-edge genes** (pathway drivers) instead of the full gene set.
- Focus on signals that are **conserved across resistant models** (cell lines / replicates), not driven by a single dataset.
- Test enrichment of **conserved coherent genes** against **conserved pathway drivers** in a shared background universe.

---

## Case study: Tamoxifen-resistant breast cancer cell lines

In the example workflow, each dataset corresponds to a resistant vs control comparison for a specific cell line (or replicate),
such as:
- `MCF7_TamR vs MCF7_WT`
- `T47D_TAMR vs T47D_WT`
- `BT474_TAMR vs BT474_WT`
- `ZR75-1_TAM2 vs ZR75-1_WT`

The pipeline produces:
1) pathway-level signals from expression (GSEA)
2) gene-level promoter methylation summaries
3) a coherent gene set bridging expression and methylation
4) enrichment results linking coherent genes back to pathway drivers

---

## What “conserved” means in MultiEnrich

A central goal of MultiEnrich is to prioritize signals that are **reproducible across multiple tamoxifen-resistant models**, rather than driven by a single cell line or a single run. In practice, “conserved” is enforced at **three checkpoints**:

### 1) Conserved pathways (shared functional signal)
Before extracting genes, MultiEnrich first selects **pathways that recur across models** (e.g., significant in at least `min_support` datasets, using `summarize_recurring_hallmarks`). This reduces noise and ensures downstream steps focus on functional programs that are consistently observed across resistant cell lines.

### 2) Conserved pathway drivers (leading-edge consensus)
For the conserved pathways, MultiEnrich extracts **leading-edge genes** (the genes driving enrichment in each dataset) and builds **pathway-specific consensus driver sets**, keeping only genes that appear repeatedly across datasets for the same pathway (e.g., `n_datasets >= min_support`). These consensus leading-edge genes represent robust pathway cores rather than full GMT gene sets.

### 3) Conserved cross-omics coherence (expression + promoter methylation)
At the gene level, MultiEnrich retains only **directionally coherent** events:
- `hyper` promoter methylation + **downregulated** expression → `hyper+down`
- `hypo` promoter methylation + **upregulated** expression → `hypo+up`

To emphasize consistency across models, coherent genes are further grouped into **robustness branches** (e.g., non-divergent, strict support thresholds). The final enrichment tests then evaluate whether these **conserved coherent gene sets** are enriched within **conserved pathway driver cores**, using a shared background universe (`RNK genes ∩ promoter methylation genes`) and Fisher exact testing with BH-FDR correction.

### 3) Final enrichment on conserved signals
We test whether **conserved coherent genes** (branch gene sets) are enriched in **conserved pathway drivers**
(pathway-specific leading-edge consensus gene sets):

- **Universe background (U):** `RNK genes ∩ promoter methylation genes`
- **Statistics:** one-sided Fisher exact test (greater) + BH-FDR correction

This produces one enrichment table per branch (and per direction when applicable), reporting:
- odds ratio, p-value, BH-FDR
- number of coherent genes in the pathway
- the coherent genes contributing to the hit


