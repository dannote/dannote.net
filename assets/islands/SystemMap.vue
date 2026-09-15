<template>
  <div class="not-prose my-rhythm-2 flex items-center gap-2 border-y border-copy/20 py-2 font-mono text-micro">
    <button class="border border-copy/55 px-2 py-1 hover:bg-copy hover:text-page" type="button" @click="zoom = Math.max(0.7, zoom - 0.1)" aria-label="Zoom out">−</button>
    <output class="min-w-12 text-center" aria-live="polite">{{ Math.round(zoom * 100) }}%</output>
    <button class="border border-copy/55 px-2 py-1 hover:bg-copy hover:text-page" type="button" @click="zoom = Math.min(1.8, zoom + 0.1)" aria-label="Zoom in">+</button>
    <button class="ml-auto border border-copy/55 px-2 py-1 hover:bg-copy hover:text-page" type="button" @click="zoom = 1">Reset</button>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from "vue";

const props = defineProps<{ target: string }>();
const zoom = ref(1);

function applyZoom() {
  document.getElementById(props.target)?.style.setProperty("--map-zoom", String(zoom.value));
}

onMounted(applyZoom);
watch(zoom, applyZoom);
</script>
