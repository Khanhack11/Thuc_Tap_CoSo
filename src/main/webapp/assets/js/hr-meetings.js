/* hr-meetings.js - externalized from hr/meetings.jsp to avoid JSP EL parsing ${...} as 500 error.
 * Fixes: accurate local -> UTC conversion + escape for title.
 */
(() => {
  const c = (document.currentScript && document.currentScript.dataset.context) || '';
  const f = document.getElementById('form');
  const rows = document.getElementById('rows');
  const msg = document.getElementById('msg');
  let token = '';

  const field = (n) => f.elements[n];
  const say = (t, isErr) => {
    msg.textContent = t;
    msg.className = 'alert alert-' + (isErr ? 'danger' : 'success');
  };

  // Escape HTML to prevent XSS when rendering title (and other strings).
  const esc = (v) => String(v == null ? '' : v)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

  // Accurate local datetime-local -> UTC ISO: parse components as local time explicitly.
  // Input "YYYY-MM-DDTHH:mm" (from <input type="datetime-local">) is local wall time.
  const iso = (v) => {
    if (!v) return '';
    const m = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(?::(\d{2}))?/.exec(v);
    if (m) {
      const d = new Date(+m[1], +m[2] - 1, +m[3], +m[4], +m[5], +(m[6] || 0));
      return d.toISOString();
    }
    // Fallback: let Date parse, then shift if needed.
    return new Date(v).toISOString();
  };

  async function load() {
    let r = await fetch(c + '/meetings?size=100');
    let d = await r.json();
    token = d.csrfToken || token;
    rows.innerHTML = (d.items || []).map((m) => `<tr><td>${esc(m.title)}</td><td>${new Date(m.startsAt).toLocaleString('vi-VN')} \u2013 ${new Date(m.endsAt).toLocaleTimeString('vi-VN')}</td><td>#${m.programId}</td><td><span class="badge ${m.status === 'CANCELLED' ? 'text-bg-secondary' : 'text-bg-success'}">${m.status}</span></td><td><span class="badge text-bg-info">${m.status === 'CANCELLED' ? 'Kh\u00f4ng g\u1eedi' : 'Theo c\u1ea5u h\u00ecnh server'}</span></td><td><button class="btn btn-sm btn-outline-primary" data-id="${m.id}">S\u1eeda</button></td></tr>`).join('') || '<tr><td colspan="6" class="text-center text-muted">Ch\u01b0a c\u00f3 l\u1ecbch h\u1ecdp.</td></tr>';
  }

  async function detail(id) {
    let d = await (await fetch(c + '/meetings?id=' + id)).json();
    let m = d.item;
    token = d.csrfToken || token;
    Object.keys(m).forEach((k) => { if (field(k)) field(k).value = Array.isArray(m[k]) ? m[k].join(',') : m[k]; });
    field('startsAt').value = m.startsAt.slice(0, 16);
    field('endsAt').value = m.endsAt.slice(0, 16);
    document.getElementById('cancel').classList.toggle('d-none', m.status === 'CANCELLED');
  }

  async function post(data) {
    let r = await fetch(c + '/meetings', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: new URLSearchParams({ ...data, csrfToken: token }) });
    let d = await r.json();
    if (!r.ok) throw Error(d.error || 'Kh\u00f4ng th\u1ec3 l\u01b0u');
  }

  f.onsubmit = async (e) => {
    e.preventDefault();
    try {
      let x = Object.fromEntries(new FormData(f));
      x.action = x.id ? 'update' : 'create';
      x.startsAt = iso(x.startsAt);
      x.endsAt = iso(x.endsAt);
      await post(x);
      say('\u0110\u00e3 l\u01b0u l\u1ecbch h\u1ecdp. Email \u0111\u01b0\u1ee3c x\u1eed l\u00fd b\u1edfi worker server, kh\u00f4ng l\u1ed9 SMTP client.', false);
      f.reset();
      field('id').value = '';
      document.getElementById('cancel').classList.add('d-none');
      load();
    } catch (e) { say(e.message, true); }
  };

  rows.onclick = (e) => { let b = e.target.closest('[data-id]'); if (b) detail(b.dataset.id); };
  document.getElementById('new').onclick = () => { f.reset(); field('id').value = ''; document.getElementById('cancel').classList.add('d-none'); };
  document.getElementById('cancel').onclick = async () => {
    if (!confirm('H\u1ee7y cu\u1ed9c h\u1ecdp n\u00e0y?')) return;
    try { await post({ action: 'cancel', id: field('id').value, revision: field('revision').value }); say('\u0110\u00e3 h\u1ee7y cu\u1ed9c h\u1ecdp.', false); load(); }
    catch (e) { say(e.message, true); }
  };

  load();
})();
