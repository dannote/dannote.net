<script setup lang="ts">
// Two drawings joined by one arrow. On top, the funnel as a flow: traffic enters
// colored by segment, every step splits it into who continued and who left, and
// the ribbons keep their colors so one segment can be watched thinning out. Below,
// one abandoned session from the fattest "left" branch, as the spans that produced
// it. Drawn as SVG sized from the container; hovering a segment follows it through.
import { computed, onBeforeUnmount, onMounted, ref } from "vue";

interface Segment {
  key: string;
  label: string;
  color: string;
}
interface Step {
  label: string;
  counts: Record<string, number>;
}
interface Span {
  label: string;
  depth: number;
  start: number;
  duration: number;
  color?: string;
  note?: string;
}

const props = defineProps<{
  segments: Segment[];
  steps: Step[];
  focus: number;
  session: string;
  spans: Span[];
  duration: number;
}>();

const root = ref<HTMLElement | null>(null);
const width = ref(720);
const active = ref<string | null>(null);
let observer: ResizeObserver | undefined;

onMounted(() => {
  observer = new ResizeObserver(([entry]) => {
    width.value = Math.max(320, Math.floor(entry.contentRect.width));
  });
  if (root.value) observer.observe(root.value);
});
onBeforeUnmount(() => observer?.disconnect());

const wide = computed(() => width.value >= 700);
const total = (step: Step) => Object.values(step.counts).reduce((sum, n) => sum + n, 0);
const format = (n: number) => n.toLocaleString("en-US");

// Flow geometry. Column 0 holds the sources as separate bars; the rest are steps.
const margin = 8;
const barWidth = computed(() => (wide.value ? 14 : 10));
const unit = computed(() => (wide.value ? 120 : 84) / total(props.steps[0]));
const flowTop = 44;
const columns = computed(() => props.steps.length + 1);
const columnWidth = computed(() => (width.value - 2 * margin) / columns.value);
const x = (column: number) => margin + column * columnWidth.value + columnWidth.value / 2;
const droppedTop = computed(() => flowTop + unit.value * total(props.steps[0]) + 36);

// Where each segment's slice sits in a step's bar.
const slice = (step: Step, key: string) => {
  let offset = 0;
  for (const segment of props.segments) {
    if (segment.key === key) break;
    offset += step.counts[segment.key] * unit.value;
  }
  return { top: flowTop + offset, height: step.counts[key] * unit.value };
};

const sourceBars = computed(() => {
  let y = flowTop;
  return props.segments.map((segment) => {
    const height = props.steps[0].counts[segment.key] * unit.value;
    const bar = { segment, top: y, height };
    y += height + 6;
    return bar;
  });
});

const band = (x1: number, top1: number, h1: number, x2: number, top2: number, h2: number) => {
  const mid = (x1 + x2) / 2;
  return `M${x1},${top1} C${mid},${top1} ${mid},${top2} ${x2},${top2} L${x2},${top2 + h2} C${mid},${top2 + h2} ${mid},${top1 + h1} ${x1},${top1 + h1} Z`;
};

interface Ribbon {
  key: string;
  color: string;
  d: string;
}

const ribbons = computed<Ribbon[]>(() => {
  const list: Ribbon[] = [];
  const half = barWidth.value / 2;
  for (const [index, bar] of sourceBars.value.entries()) {
    const target = slice(props.steps[0], bar.segment.key);
    list.push({
      key: bar.segment.key,
      color: bar.segment.color,
      d: band(x(0) + half, bar.top, bar.height, x(1) - half, target.top, target.height),
    });
    void index;
  }
  for (let i = 0; i < props.steps.length - 1; i++) {
    const from = props.steps[i];
    const to = props.steps[i + 1];
    let droppedOffset = droppedTop.value;
    for (const segment of props.segments) {
      const source = slice(from, segment.key);
      const target = slice(to, segment.key);
      const leftHeight = source.height - target.height;
      list.push({
        key: segment.key,
        color: segment.color,
        d: band(x(i + 1) + half, source.top, target.height, x(i + 2) - half, target.top, target.height),
      });
      if (leftHeight > 0) {
        list.push({
          key: segment.key,
          color: segment.color,
          d: band(x(i + 1) + half, source.top + target.height, leftHeight, x(i + 1.5) - half, droppedOffset, leftHeight),
        });
        droppedOffset += leftHeight;
      }
    }
  }
  return list;
});

const dropped = computed(() =>
  props.steps.slice(0, -1).map((from, i) => {
    const to = props.steps[i + 1];
    const left = total(from) - total(to);
    let offset = droppedTop.value;
    const slices = props.segments.map((segment) => {
      const height = (from.counts[segment.key] - to.counts[segment.key]) * unit.value;
      const rect = { segment, top: offset, height };
      offset += height;
      return rect;
    });
    return { index: i, x: x(i + 1.5), left, share: Math.round((100 * left) / total(from)), slices };
  }),
);

const flowBottom = computed(() => droppedTop.value + Math.max(...dropped.value.map((d) => d.left)) * unit.value + 52);

// Trace geometry.
const rowHeight = 20;
const traceTop = computed(() => flowBottom.value + 64);
const labelWidth = computed(() => (wide.value ? 200 : 162));
const traceRight = computed(() => width.value - (wide.value ? 112 : 8));
const tx = (ms: number) => labelWidth.value + ((traceRight.value - labelWidth.value) * ms) / props.duration;
const ticks = computed(() => {
  const count = wide.value ? 4 : 2;
  const step = props.duration / count;
  return Array.from({ length: count + 1 }, (_, i) => ({ ms: i * step, x: tx(i * step) }));
});
const height = computed(() => traceTop.value + props.spans.length * rowHeight + 12);

const ribbonOpacity = (key: string) => (active.value === null ? 0.35 : active.value === key ? 0.6 : 0.08);
const barOpacity = (key: string) => (active.value === null || active.value === key ? 1 : 0.3);
</script>

<template>
  <div ref="root" class="w-full">
    <svg
      :viewBox="`0 0 ${width} ${height}`"
      :width="width"
      :height="height"
      class="block max-w-full"
      style="color: var(--color-copy)"
      role="img"
      aria-label="A funnel drawn as a flow splitting by campaign creative, and one abandoned session drawn as spans."
    >
      <g font-size="11" fill="currentColor" style="color: var(--color-dim)">
        <g
          v-for="(segment, i) in segments"
          :key="segment.key"
          :transform="`translate(${margin + i * (wide ? 150 : 104)}, 12)`"
          class="cursor-pointer"
          @mouseenter="active = segment.key"
          @mouseleave="active = null"
        >
          <rect x="0" y="-6" width="10" height="10" :style="segment.color" fill="currentColor" />
          <text x="16" y="3">{{ wide ? segment.label : segment.label.replace("spring · ", "") }}</text>
        </g>
      </g>

      <g v-for="(step, i) in steps" :key="step.label" font-size="10" fill="currentColor">
        <text :x="x(i + 1)" :y="flowTop - (wide ? 8 : 18)" text-anchor="middle" style="color: var(--color-dim)">
          {{ wide ? step.label : step.label.replace("Signup · ", "") }}
          <tspan v-if="wide" font-family="var(--font-mono)" style="color: var(--color-copy)"> {{ format(total(step)) }}</tspan>
        </text>
        <text v-if="!wide" :x="x(i + 1)" :y="flowTop - 6" text-anchor="middle" font-family="var(--font-mono)">
          {{ format(total(step)) }}
        </text>
      </g>

      <path
        v-for="(ribbon, i) in ribbons"
        :key="i"
        :d="ribbon.d"
        :style="ribbon.color"
        fill="currentColor"
        :opacity="ribbonOpacity(ribbon.key)"
        class="transition-opacity"
      />

      <g v-for="bar in sourceBars" :key="bar.segment.key" :style="bar.segment.color" :opacity="barOpacity(bar.segment.key)">
        <rect :x="x(0) - barWidth / 2" :y="bar.top" :width="barWidth" :height="bar.height" fill="currentColor" />
        <text
          v-if="wide"
          :x="x(0) - barWidth / 2 - 6"
          :y="bar.top + bar.height / 2 + 3"
          text-anchor="end"
          font-size="10"
          font-family="var(--font-mono)"
          fill="currentColor"
        >
          {{ format(steps[0].counts[bar.segment.key]) }}
        </text>
      </g>

      <g v-for="(step, i) in steps" :key="'bar' + step.label">
        <rect
          v-for="segment in segments"
          :key="segment.key"
          :x="x(i + 1) - barWidth / 2"
          :y="slice(step, segment.key).top"
          :width="barWidth"
          :height="slice(step, segment.key).height"
          :style="segment.color"
          fill="currentColor"
          :opacity="barOpacity(segment.key)"
          class="cursor-pointer"
          @mouseenter="active = segment.key"
          @mouseleave="active = null"
        />
      </g>

      <g v-for="drop in dropped" :key="'drop' + drop.index">
        <rect
          v-for="rect in drop.slices"
          :key="rect.segment.key"
          :x="drop.x - barWidth / 2"
          :y="rect.top"
          :width="barWidth"
          :height="rect.height"
          :style="rect.segment.color"
          fill="currentColor"
          :opacity="barOpacity(rect.segment.key)"
        />
        <text
          :x="drop.x"
          :y="droppedTop + drop.left * unit + 14"
          text-anchor="middle"
          font-size="10"
          fill="currentColor"
          style="color: var(--color-dim)"
        >
          <template v-if="wide">left <tspan font-family="var(--font-mono)" style="color: var(--color-copy)">{{ format(drop.left) }}</tspan> · </template>{{ drop.share }} %
        </text>
      </g>

      <g style="color: var(--color-accent)" fill="currentColor" stroke="currentColor">
        <text :x="dropped[focus].x" :y="droppedTop + dropped[focus].left * unit + 38" text-anchor="middle" font-size="10" stroke="none">
          one of them
        </text>
        <line
          :x1="dropped[focus].x"
          :x2="dropped[focus].x"
          :y1="droppedTop + dropped[focus].left * unit + 44"
          :y2="traceTop - 30"
          stroke-width="1"
          stroke-dasharray="2 3"
        />
      </g>

      <g font-size="10" style="color: var(--color-dim)" fill="currentColor">
        <text :x="margin" :y="traceTop - 26">{{ session }}</text>
        <line
          :x1="labelWidth"
          :x2="traceRight"
          :y1="traceTop - 4"
          :y2="traceTop - 4"
          stroke="var(--color-rule)"
          stroke-width="1"
        />
        <g v-for="tick in ticks" :key="tick.ms">
          <line :x1="tick.x" :x2="tick.x" :y1="traceTop - 4" :y2="traceTop + spans.length * rowHeight" stroke="var(--color-rule)" stroke-width="1" />
          <text :x="tick.x" :y="traceTop - 8" :text-anchor="tick.ms === duration && !wide ? 'end' : 'middle'" font-family="var(--font-mono)">
            {{ format(tick.ms) }}<tspan v-if="tick.ms === 0"> ms</tspan>
          </text>
        </g>
      </g>

      <g v-for="(span, i) in spans" :key="i" :style="span.color || 'color: var(--color-copy)'">
        <line
          v-if="i > 0"
          :x1="margin"
          :x2="traceRight"
          :y1="traceTop + i * rowHeight - 0.5"
          :y2="traceTop + i * rowHeight - 0.5"
          stroke="var(--color-rule)"
          stroke-width="1"
        />
        <text
          :x="margin + span.depth * (wide ? 14 : 7)"
          :y="traceTop + i * rowHeight + 13"
          font-size="10"
          font-family="var(--font-mono)"
          fill="currentColor"
        >
          {{ span.label }}
        </text>
        <rect
          :x="tx(span.start)"
          :y="traceTop + i * rowHeight + 4"
          :width="Math.max(2, tx(span.start + span.duration) - tx(span.start))"
          height="10"
          fill="currentColor"
          :opacity="span.color ? 0.9 : 0.35"
        />
        <text
          v-if="span.note && wide"
          :x="traceRight + 8"
          :y="traceTop + i * rowHeight + 13"
          font-size="10"
          font-family="var(--font-mono)"
          fill="currentColor"
        >
          {{ span.note }}
        </text>
      </g>
    </svg>
  </div>
</template>
