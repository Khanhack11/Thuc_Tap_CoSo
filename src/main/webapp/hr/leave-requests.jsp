<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Duyệt nghỉ phép" />
<c:set var="activePage" value="leave-requests" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.hr-leaves .panel{border:0;border-radius:1rem;box-shadow:0 .35rem 1.2rem #172b4d12}.hr-leaves .table td{vertical-align:middle}.hr-leaves .state{min-height:3rem}.hr-leaves .reason{white-space:pre-wrap;overflow-wrap:anywhere;max-width:24rem}
</style>
<div class="container-fluid py-4 hr-leaves" id="leaveApp" data-api="${pageContext.request.contextPath}/api/hr/leave-requests">
 <div class="mb-4"><h2 class="h4 mb-1">Duyệt nghỉ phép</h2><p class="text-muted mb-0">Lọc và xử lý đơn nghỉ của thực tập sinh đang thuộc chương trình.</p></div>
 <div id="leaveAlert" class="state" role="status" aria-live="polite"></div>
 <section class="card panel"><div class="card-body p-4">
  <form id="filterForm" class="row g-3 align-items-end mb-4">
   <div class="col-sm-6 col-lg-2"><label class="form-label" for="filterFrom">Từ ngày *</label><input class="form-control" id="filterFrom" type="date" required></div>
   <div class="col-sm-6 col-lg-2"><label class="form-label" for="filterTo">Đến ngày *</label><input class="form-control" id="filterTo" type="date" required></div>
   <div class="col-sm-6 col-lg-2"><label class="form-label" for="filterProgram">Mã chương trình</label><input class="form-control" id="filterProgram" type="number" min="1" placeholder="Tất cả"></div>
   <div class="col-sm-6 col-lg-2"><label class="form-label" for="filterStatus">Trạng thái</label><select class="form-select" id="filterStatus"><option value="">Tất cả</option><option value="PENDING">Chờ duyệt</option><option value="APPROVED">Đã duyệt</option><option value="REJECTED">Từ chối</option></select></div>
   <div class="col-auto"><button class="btn btn-primary" type="submit">Lọc đơn</button></div>
  </form>
  <div class="table-responsive"><table class="table table-hover align-middle"><thead><tr><th>Thực tập sinh</th><th>Chương trình</th><th>Thời gian nghỉ</th><th>Lý do</th><th>Trạng thái</th><th>Lý do từ chối</th><th>Thao tác</th></tr></thead><tbody id="leaveRows"><tr><td colspan="7" class="text-center text-muted py-4">Đang tải đơn nghỉ…</td></tr></tbody></table></div>
 </div></section>
</div>
<input type="hidden" id="csrfToken" name="csrfToken" value="">

<div class="modal fade" id="rejectModal" tabindex="-1" aria-labelledby="rejectTitle" aria-hidden="true"><div class="modal-dialog modal-dialog-centered"><div class="modal-content"><form id="rejectForm" novalidate><div class="modal-header"><h2 class="modal-title fs-5" id="rejectTitle">Từ chối đơn nghỉ</h2><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button></div><div class="modal-body"><input type="hidden" id="rejectLeaveId"><label class="form-label" for="rejectReason">Lý do từ chối *</label><textarea class="form-control" id="rejectReason" rows="4" maxlength="1000" required></textarea><div class="invalid-feedback">Nhập lý do (tối đa 1000 ký tự).</div><div class="form-text">Lý do sẽ được lưu và hiển thị trong lịch sử đơn.</div></div><div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button><button type="submit" class="btn btn-danger">Xác nhận từ chối</button></div></form></div></div></div>

<script>
(() => {
 const root=document.getElementById('leaveApp'),api=root.dataset.api,$=id=>document.getElementById(id),alertBox=$('leaveAlert');let token='';
 const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
 const dateText=d=>d?new Date(d+'T00:00:00').toLocaleDateString('vi-VN'):'';
 function flash(text,type='info'){alertBox.innerHTML=`<div class="alert alert-${type} py-2" role="alert">${esc(text)}</div>`;}
  async function call(url,options={}){const r=await fetch(url,{credentials:'same-origin',...options});const ct=r.headers.get('content-type')||'';if(r.redirected||!ct.includes('application/json'))throw Error('Phiên đăng nhập hết hạn hoặc phản hồi không hợp lệ. Hãy tải lại trang.');const b=await r.json();if(b.csrfToken){token=b.csrfToken;$('csrfToken').value=token;}if(!r.ok||b.success===false&&!b.data)throw Error(b.error?.message||`Lỗi HTTP ${r.status}`);return{body:b,response:r};}
 function query(){const q=new URLSearchParams({from:$('filterFrom').value,to:$('filterTo').value});if($('filterProgram').value)q.set('programId',$('filterProgram').value);if($('filterStatus').value)q.set('status',$('filterStatus').value);return q;}
 function status(s){return s==='PENDING'?['Chờ duyệt','text-bg-warning']:s==='APPROVED'?['Đã duyệt','text-bg-success']:['Từ chối','text-bg-danger'];}
 function render(rows){const t=$('leaveRows');if(!rows.length){t.innerHTML='<tr><td colspan="7" class="text-center text-muted py-5"><strong>Không có đơn nghỉ phù hợp.</strong><br>Thử thay đổi bộ lọc.</td></tr>';return;}t.innerHTML=rows.map(l=>{const[label,cls]=status(l.status);return `<tr><td><strong>${esc(l.internName)}</strong><br><span class="text-muted">Enrollment #${esc(l.enrollmentId)}</span></td><td>${esc(l.programName)}</td><td>${esc(dateText(l.fromDate))} – ${esc(dateText(l.toDate))}</td><td><div class="reason">${esc(l.reason)}</div></td><td><span class="badge ${cls}">${label}</span></td><td><div class="reason">${esc(l.rejectReason||'—')}</div></td><td>${l.status==='PENDING'?`<div class="d-flex gap-1"><button class="btn btn-sm btn-success" data-approve="${Number(l.leaveId)}">Duyệt</button><button class="btn btn-sm btn-outline-danger" data-reject="${Number(l.leaveId)}">Từ chối</button></div>`:'<span class="text-muted small">Đã xử lý</span>'}</td></tr>`;}).join('');}
 async function load(){if(!$('filterForm').reportValidity())return;$('leaveRows').innerHTML='<tr><td colspan="7" class="text-center py-4">Đang tải…</td></tr>';try{const b=await call(`${api}?${query()}`);render(b.data||[]);}catch(e){$('leaveRows').innerHTML='<tr><td colspan="7" class="text-center text-danger py-4">Không tải được danh sách đơn.</td></tr>';flash(e.message,'danger');}}
 async function decide(action,id,reason=''){const p=new URLSearchParams({action,csrfToken:token,leaveId:id});if(action==='reject')p.set('rejectReason',reason);return call(api,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body:p.toString()});}
 $('filterForm').addEventListener('submit',e=>{e.preventDefault();load();});
 $('leaveRows').addEventListener('click',async e=>{const a=e.target.closest('[data-approve]'),r=e.target.closest('[data-reject]');if(a){if(!confirm('Duyệt đơn nghỉ này?'))return;try{await decide('approve',a.dataset.approve);flash('Đã duyệt đơn nghỉ.','success');await load();}catch(err){flash(err.message,'danger');}}if(r){$('rejectLeaveId').value=r.dataset.reject;$('rejectReason').value='';bootstrap.Modal.getOrCreateInstance($('rejectModal')).show();}});
 $('rejectForm').addEventListener('submit',async e=>{e.preventDefault();if(!e.currentTarget.reportValidity())return;try{await decide('reject',$('rejectLeaveId').value,$('rejectReason').value);bootstrap.Modal.getOrCreateInstance($('rejectModal')).hide();flash('Đã từ chối đơn nghỉ và lưu lý do.','success');await load();}catch(err){flash(err.message,'danger');}});
  const today=new Date(),from=new Date(today.getTime()-30*86400000),iso=d=>new Date(d-d.getTimezoneOffset()*60000).toISOString().slice(0,10);$('filterFrom').value=iso(from);$('filterTo').value=iso(today);
  try{const r=await fetch(`${api}?from=${iso(from)}&to=${iso(today)}`,{credentials:'same-origin'});const b=await r.json();if(!r.ok||!b.csrfToken)throw Error(b.error?.message||'Không lấy được CSRF token.');token=b.csrfToken;}catch(e){flash(e.message,'danger');}
  load();
})();
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>