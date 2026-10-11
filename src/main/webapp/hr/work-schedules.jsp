<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Lịch làm việc" />
<c:set var="activePage" value="schedules" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.hr-schedule .panel{border:0;border-radius:1rem;box-shadow:0 .35rem 1.2rem #172b4d12}.hr-schedule .state{min-height:3rem}.hr-schedule .table td{vertical-align:middle}.hr-schedule .help{font-size:.875rem;color:#667085}
</style>
<div class="container-fluid py-4 hr-schedule" id="scheduleApp" data-api="${pageContext.request.contextPath}/api/hr/work-schedules">
 <div class="mb-4"><h2 class="h4 mb-1">Lịch làm việc</h2><p class="text-muted mb-0">Thiết lập ca theo mã ghi danh, theo dõi lịch và xung đột.</p></div>
 <div id="scheduleAlert" class="state" role="status" aria-live="polite"></div>
 <div class="row g-4">
  <div class="col-xl-4"><section class="card panel"><div class="card-body p-4">
   <h3 class="h5 mb-3">Thiết lập ca làm</h3>
   <form id="scheduleForm" novalidate>
    <input type="hidden" id="csrfToken">
    <div class="mb-3"><label class="form-label" for="enrollmentId">Mã ghi danh thực tập sinh *</label><input class="form-control" id="enrollmentId" type="number" min="1" step="1" required><div class="invalid-feedback">Nhập mã ghi danh hợp lệ.</div><div class="help mt-1">API sử dụng enrollmentId, không dùng mentor assignment.</div></div>
    <div class="mb-3"><label class="form-label" for="workDate">Ngày làm việc *</label><input class="form-control" id="workDate" type="date" required><div class="invalid-feedback">Chọn ngày làm việc.</div></div>
    <div class="row g-3 mb-3"><div class="col-6"><label class="form-label" for="startTime">Bắt đầu *</label><input class="form-control" id="startTime" type="time" required><div class="invalid-feedback">Chọn giờ bắt đầu.</div></div><div class="col-6"><label class="form-label" for="endTime">Kết thúc *</label><input class="form-control" id="endTime" type="time" required><div class="invalid-feedback">Giờ kết thúc phải sau giờ bắt đầu.</div></div></div>
    <div class="mb-3"><label class="form-label" for="note">Ghi chú</label><textarea class="form-control" id="note" rows="2" maxlength="500"></textarea><div class="form-text">Tối đa 500 ký tự; không hỗ trợ ca qua đêm.</div></div>
    <div class="d-flex flex-wrap gap-2"><button class="btn btn-primary" type="submit">Lưu ca</button><button class="btn btn-outline-primary" type="button" id="bulkToggle">Tạo ca theo nhóm</button></div>
   </form>
   <form id="bulkForm" class="mt-4 pt-3 border-top d-none" novalidate><h4 class="h6">Tạo nhiều ca</h4><label class="form-label" for="enrollmentIds">Mã ghi danh, cách nhau bằng dấu phẩy *</label><textarea class="form-control mb-2" id="enrollmentIds" rows="2" required placeholder="101, 102, 103"></textarea><div class="form-text mb-3">Tối đa 100 mã duy nhất. Dùng cùng ngày, giờ và ghi chú bên trên.</div><button class="btn btn-outline-primary" type="submit">Lưu theo nhóm</button></form>
  </div></section></div>
  <div class="col-xl-8"><section class="card panel"><div class="card-body p-4">
   <div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mb-3"><h3 class="h5 mb-0">Tra cứu lịch</h3><form id="filterForm" class="row g-2 align-items-end"><div class="col-auto"><label class="form-label small mb-1" for="filterFrom">Từ ngày</label><input class="form-control form-control-sm" id="filterFrom" type="date" required></div><div class="col-auto"><label class="form-label small mb-1" for="filterTo">Đến ngày</label><input class="form-control form-control-sm" id="filterTo" type="date" required></div><div class="col-auto"><label class="form-label small mb-1" for="filterProgram">Mã chương trình</label><input class="form-control form-control-sm" id="filterProgram" type="number" min="1" placeholder="Tất cả"></div><div class="col-auto"><button class="btn btn-sm btn-dark" type="submit">Lọc</button></div></form></div>
   <div class="table-responsive"><table class="table table-hover"><thead><tr><th>Ngày / giờ</th><th>Thực tập sinh</th><th>Chương trình</th><th>Ghi chú</th><th>Trạng thái</th><th></th></tr></thead><tbody id="scheduleRows"><tr><td colspan="6" class="text-center text-muted py-4">Đang tải lịch…</td></tr></tbody></table></div>
  </div></section></div>
 </div>
</div>
<script>
(() => {
 const root=document.getElementById('scheduleApp'),api=root.dataset.api,$=id=>document.getElementById(id),alertBox=$('scheduleAlert');let token='';
 const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
 const now=new Date(),today=new Date(now-now.getTimezoneOffset()*60000).toISOString().slice(0,10);$('workDate').min=today;
 const localDate=d=>d?new Date(d+'T00:00:00').toLocaleDateString('vi-VN'):'';
 function flash(text,type='info'){alertBox.innerHTML=`<div class="alert alert-${type} py-2" role="alert">${esc(text)}</div>`;}
 async function call(url,options={}){const r=await fetch(url,{credentials:'same-origin',...options});const ct=r.headers.get('content-type')||'';if(r.redirected||!ct.includes('application/json'))throw Error('Phiên đăng nhập hết hạn hoặc phản hồi không hợp lệ. Hãy tải lại trang.');const b=await r.json();if(b.csrfToken){token=b.csrfToken;$('csrfToken').value=token;}if(!r.ok||b.success===false&&!b.data)throw Error(b.error?.message||`Lỗi HTTP ${r.status}`);return{body:b,response:r};}
 const post=data=>call(api,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body:data.toString()});
 function query(){const q=new URLSearchParams({from:$('filterFrom').value,to:$('filterTo').value});if($('filterProgram').value)q.set('programId',$('filterProgram').value);return q;}
 function render(rows){const target=$('scheduleRows');if(!rows.length){target.innerHTML='<tr><td colspan="6" class="text-center text-muted py-5"><strong>Chưa có ca làm trong khoảng ngày đã chọn.</strong><br>Đổi bộ lọc hoặc tạo ca mới.</td></tr>';return;}target.innerHTML=rows.map(s=>`<tr><td>${esc(localDate(s.workDate))}<br><span class="text-muted">${esc(s.startTime)}–${esc(s.endTime)}</span></td><td>${esc(s.internName)} <span class="text-muted">(#${esc(s.enrollmentId)})</span></td><td>${esc(s.programName)}</td><td>${esc(s.note||'—')}</td><td><span class="badge ${s.status==='CANCELLED'?'text-bg-secondary':'text-bg-success'}">${s.status==='CANCELLED'?'Đã hủy':'Đang hiệu lực'}</span>${s.approvedLeave?' <span class="badge text-bg-warning">Đã duyệt nghỉ</span>':''}</td><td>${s.status!=='CANCELLED'?`<button class="btn btn-sm btn-outline-danger" data-cancel="${Number(s.scheduleId)}">Hủy ca</button>`:''}</td></tr>`).join('');}
  const today=new Date(),from=new Date(Date.now()-7*86400000),iso=d=>new Date(d-d.getTimezoneOffset()*60000).toISOString().slice(0,10);$('filterFrom').value=iso(from);$('filterTo').value=iso(today);

 async function load(){if(!$('filterForm').reportValidity())return;$('scheduleRows').innerHTML='<tr><td colspan="6" class="text-center py-4">Đang tải…</td></tr>';try{const{body}=await call(`${api}?${query()}`);render(body.data||[]);}catch(e){$('scheduleRows').innerHTML='<tr><td colspan="6" class="text-center text-danger py-4">Không tải được danh sách lịch.</td></tr>';flash(e.message,'danger');}}
 function validTime(){if($('endTime').value<=$('startTime').value){$('endTime').setCustomValidity('Giờ kết thúc phải sau giờ bắt đầu.');$('endTime').reportValidity();$('endTime').setCustomValidity('');return false;}return true;}
 $('scheduleForm').addEventListener('submit',async e=>{e.preventDefault();if(!e.currentTarget.reportValidity()||!validTime())return;try{await post(new URLSearchParams({action:'create',csrfToken:token,enrollmentId:$('enrollmentId').value,workDate:$('workDate').value,startTime:$('startTime').value,endTime:$('endTime').value,note:$('note').value}));flash('Đã lưu ca làm thành công.','success');await load();}catch(err){flash(err.message,'danger');}});
 $('bulkToggle').addEventListener('click',()=>$('bulkForm').classList.toggle('d-none'));
 $('bulkForm').addEventListener('submit',async e=>{e.preventDefault();if(!$('scheduleForm').reportValidity()||!e.currentTarget.reportValidity()||!validTime())return;const ids=[...new Set($('enrollmentIds').value.split(',').map(x=>x.trim()).filter(Boolean))];if(!ids.length||ids.length>100||ids.some(x=>!/^[1-9]\d*$/.test(x))){flash('Nhập 1–100 mã ghi danh dương, phân tách bằng dấu phẩy.','warning');return;}try{const{body}=await post(new URLSearchParams({action:'bulk-create',csrfToken:token,enrollmentIds:ids.join(','),workDate:$('workDate').value,startTime:$('startTime').value,endTime:$('endTime').value,note:$('note').value}));const d=body.data||{},failed=(d.results||[]).filter(x=>!x.success);flash(`${d.successCount||0} ca đã lưu; ${d.failureCount||0} ca lỗi.${failed.length?' Xung đột/không hợp lệ: '+failed.map(x=>x.enrollmentId+' ('+x.errorCode+')').join(', '):''}`,failed.length?'warning':'success');await load();}catch(err){flash(err.message,'danger');}});
 $('filterForm').addEventListener('submit',e=>{e.preventDefault();load();});
 $('scheduleRows').addEventListener('click',async e=>{const b=e.target.closest('[data-cancel]');if(!b||!confirm('Hủy ca này?'))return;try{await post(new URLSearchParams({action:'cancel',csrfToken:token,scheduleId:b.dataset.cancel}));flash('Đã hủy ca.','success');await load();}catch(err){flash(err.message,'danger');}});
  const today=new Date(),from=new Date(Date.now()-7*86400000),iso=d=>new Date(d-d.getTimezoneOffset()*60000).toISOString().slice(0,10);$('filterFrom').value=iso(from);$('filterTo').value=iso(today);
  try{const r=await fetch(`${api}?from=${iso(today)}&to=${iso(today)}`,{credentials:'same-origin'});const b=await r.json();if(!r.ok||!b.csrfToken)throw Error(b.error?.message||'Không lấy được CSRF token.');token=b.csrfToken;$('csrfToken').value=token;}catch(e){flash(e.message,'danger');}
  load();
})();
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
