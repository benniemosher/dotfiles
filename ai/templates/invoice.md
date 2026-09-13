---
type: invoice
client:
invoice_number: <% tp.date.now("YYYYMMDD") %>
date: <% tp.date.now("YYYY-MM-DD") %>
due_date: <% tp.date.now("YYYY-MM-DD", 15) %>
period_start:
period_end:
rate:
terms: Net 15
status: draft
tags: [invoice]
cssclass: invoice
---

<div class="invoice-header" style="display:flex;align-items:center;justify-content:space-between;background:#4c1d95;color:#ffffff;padding:1em 1.25em;border-radius:6px;margin-bottom:1.5em;">

<div style="margin:0;font-size:1.6em;letter-spacing:.12em;font-weight:700;color:#ffffff;">INVOICE</div>
<div class="invoice-number" style="color:rgba(255,255,255,0.85);font-size:0.95em;">№ <% tp.date.now("YYYYMMDD") %></div>

</div>

<div class="invoice-meta" style="display:flex;justify-content:space-between;gap:2em;margin-bottom:1.5em;padding-bottom:1em;border-bottom:1px solid #e6e0f0;">

<div class="invoice-from" style="flex:1;">

<div style="text-transform:uppercase;font-size:0.75em;letter-spacing:.06em;color:#6b6172;margin-bottom:0.4em;">From</div>

Bennie Mosher
benniemosher@gmail.com
970-590-2040

</div>

<div class="invoice-to" style="flex:1;">

<div style="text-transform:uppercase;font-size:0.75em;letter-spacing:.06em;color:#6b6172;margin-bottom:0.4em;">Bill To</div>



</div>

<div class="invoice-dates" style="flex:1;text-align:right;">

<div style="text-transform:uppercase;font-size:0.75em;letter-spacing:.06em;color:#6b6172;margin-bottom:0.4em;">Details</div>

**Date:** <% tp.date.now("YYYY-MM-DD") %>
**Due:** <% tp.date.now("YYYY-MM-DD", 15) %>
**Terms:** Net 15
<span style="white-space:nowrap;">**Period:** –</span>

</div>

</div>

<div class="invoice-summary-page" style="page-break-after:always;break-after:page;">

<div style="text-transform:uppercase;font-size:0.8em;font-weight:700;letter-spacing:.08em;color:#6b6172;border-bottom:1px solid #e6e0f0;padding-bottom:0.4em;margin-bottom:1em;">Summary</div>

<!-- One row per category, ordered by hours descending. Reuse the canonical
     category list in time-tracking.md before inventing a new label — see
     "Rules for AI Assistants" there. Column order is Category, Hours, Rate, Amount
     — Rate lives here, not on the detail-page day tables. -->
<table style="width:100%;border-collapse:collapse;margin:0.5em 0 1em;font-size:0.95em;">
<thead>
<tr>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:10px 12px;text-align:left;font-size:0.8em;text-transform:uppercase;letter-spacing:.04em;">Category</th>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:10px 12px;text-align:right;font-size:0.8em;text-transform:uppercase;letter-spacing:.04em;">Hours</th>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:10px 12px;text-align:right;font-size:0.8em;text-transform:uppercase;letter-spacing:.04em;">Rate</th>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:10px 12px;text-align:right;font-size:0.8em;text-transform:uppercase;letter-spacing:.04em;">Amount</th>
</tr>
</thead>
<tbody>
<tr><td style="padding:9px 12px;border-bottom:1px solid #e6e0f0;"></td><td style="padding:9px 12px;border-bottom:1px solid #e6e0f0;text-align:right;"></td><td style="padding:9px 12px;border-bottom:1px solid #e6e0f0;text-align:right;"></td><td style="padding:9px 12px;border-bottom:1px solid #e6e0f0;text-align:right;"></td></tr>
</tbody>
<tfoot>
<tr style="background:#4c1d95;color:#ffffff;font-weight:700;font-size:1.05em;">
<td style="padding:11px 12px;border-radius:0 0 0 6px;">Total</td>
<td style="padding:11px 12px;text-align:right;">0.00</td>
<td style="padding:11px 12px;text-align:right;"></td>
<td style="padding:11px 12px;text-align:right;border-radius:0 0 6px 0;">$0.00</td>
</tr>
</tfoot>
</table>

<div class="invoice-payment" style="margin-top:1.5em;padding-top:1em;border-top:1px solid #e6e0f0;font-size:0.9em;color:#6b6172;">

**Payment:** Direct deposit (arranged separately)

</div>

</div>

<div class="invoice-detail-page">

<div style="text-transform:uppercase;font-size:0.8em;font-weight:700;letter-spacing:.08em;color:#6b6172;border-bottom:1px solid #e6e0f0;padding-bottom:0.4em;margin-bottom:1em;">Detail</div>

<!-- One day-header bar + table per calendar day in the period, mirroring
     Hours.md's per-day sections. Category column must match the Summary
     table above so a reader can trace any rollup back to its line items.
     No Rate column here — Rate lives on the Summary page only. End each
     day's table with a bold "Day Total" row; day totals must sum to the
     Summary page's Total row. -->
<div style="page-break-inside:avoid;break-inside:avoid;">

<div style="background:#4c1d95;color:#ffffff;padding:0.5em 0.9em;font-weight:700;font-size:0.95em;margin:0 0 0.5em;border-radius:4px;"></div>

<table style="width:100%;border-collapse:collapse;margin:0 0 1.4em;font-size:0.85em;">
<thead>
<tr>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:8px 10px;text-align:left;font-size:0.75em;text-transform:uppercase;letter-spacing:.03em;">Category</th>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:8px 10px;text-align:left;font-size:0.75em;text-transform:uppercase;letter-spacing:.03em;">Description</th>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:8px 10px;text-align:right;font-size:0.75em;text-transform:uppercase;letter-spacing:.03em;">Hours</th>
<th style="background:#f5f3ff;color:#4c1d95;border-bottom:2px solid #4c1d95;padding:8px 10px;text-align:right;font-size:0.75em;text-transform:uppercase;letter-spacing:.03em;">Amount</th>
</tr>
</thead>
<tbody>
<tr><td style="padding:7px 10px;border-bottom:1px solid #e6e0f0;"></td><td style="padding:7px 10px;border-bottom:1px solid #e6e0f0;"></td><td style="padding:7px 10px;border-bottom:1px solid #e6e0f0;text-align:right;"></td><td style="padding:7px 10px;border-bottom:1px solid #e6e0f0;text-align:right;"></td></tr>
<tr style="background:#f5f3ff;font-weight:700;"><td style="padding:8px 10px;">Day Total</td><td style="padding:8px 10px;"></td><td style="padding:8px 10px;text-align:right;"></td><td style="padding:8px 10px;text-align:right;"></td></tr>
</tbody>
</table>

</div>

</div>
