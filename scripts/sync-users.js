// dir: /talung-sso/scripts
import fs from 'node:fs/promises'
import path from 'node:path'

const envPath = path.resolve(process.cwd(), '.env.local')
const env = Object.fromEntries(
  (await fs.readFile(envPath, 'utf8'))
    .split('\n')
    .map(l => l.trim())
    .filter(l => l && !l.startsWith('#'))
    .map(l => l.split('='))
)

const BASE = env.KEYCLOAK_URL || 'http://localhost:18080'
const REALM = env.KEYCLOAK_REALM || 'talung'
const ADMIN = env.KEYCLOAK_ADMIN || 'admin'
const PASS = env.KEYCLOAK_ADMIN_PASSWORD || 'adminpass'

async function getToken() {
  const res = await fetch(`${BASE}/realms/master/protocol/openid-connect/token`, {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: new URLSearchParams({
      username: ADMIN, password: PASS, grant_type: 'password', client_id: 'admin-cli'
    })
  })
  const json = await res.json()
  if (!json.access_token) throw new Error('Cannot get admin token')
  return json.access_token
}

function parseCSV(text){
  const lines = text.split(/\r?\n/).filter(l => l.trim() && !l.trim().startsWith('#'))
  const header = lines.shift().split(',').map(s=>s.trim())
  return lines.map(line=>{
    const cells = []
    let cur = '', inQuotes = false
    for (let i=0;i<line.length;i++){
      const ch = line[i]
      if (ch === '"'){ inQuotes = !inQuotes; continue }
      if (ch === ',' && !inQuotes){ cells.push(cur.trim()); cur=''; continue }
      cur += ch
    }
    cells.push(cur.trim())
    const obj = {}
    header.forEach((h,idx)=> obj[h] = (cells[idx]||'').trim())
    return obj
  })
}

async function findUserByEmail(token, email){
  const res = await fetch(`${BASE}/admin/realms/${REALM}/users?email=${encodeURIComponent(email)}`, {
    headers: { Authorization: `Bearer ${token}` }
  })
  const arr = await res.json()
  return arr && arr[0]
}

async function createUser(token, row){
  const body = {
    username: row.email,
    email: row.email,
    enabled: true,
    firstName: row.full_name,
    attributes: {
      employee_id: [row.employee_id],
      department: [row.department],
      position: [row.position]
    }
  }
  const res = await fetch(`${BASE}/admin/realms/${REALM}/users`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type':'application/json' },
    body: JSON.stringify(body)
  })
  if (res.status !== 201 && res.status !== 409){
    throw new Error(`Create user ${row.email} failed: ${res.status} ${await res.text()}`)
  }
  // Nếu 409 (đã tồn tại) thì thôi
}

async function getRoleId(token, roleName){
  const res = await fetch(`${BASE}/admin/realms/${REALM}/roles/${encodeURIComponent(roleName)}`, {
    headers: { Authorization: `Bearer ${token}` }
  })
  if (res.status !== 200) return null
  return await res.json()
}

async function getUserId(token, email){
  const u = await findUserByEmail(token, email)
  return u?.id
}

async function setPasswordIfEmpty(token, userId){
  // Đặt mật khẩu mặc định nếu chưa có (Keycloak cho phép set thẳng)
  const res = await fetch(`${BASE}/admin/realms/${REALM}/users/${userId}/reset-password`, {
    method: 'PUT',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type':'application/json' },
    body: JSON.stringify({ type:'password', value:'Talung@123', temporary:true })
  })
  if (![204, 409].includes(res.status)) {
    console.warn('Set pwd result:', res.status, await res.text())
  }
}

async function assignRoles(token, userId, rolesCsv){
  if (!rolesCsv) return
  const names = rolesCsv.split(',').map(s=>s.trim()).filter(Boolean)
  const roleObjs = []
  for (const n of names){
    const r = await getRoleId(token, n)
    if (r) roleObjs.push({ id: r.id, name: r.name })
  }
  if (!roleObjs.length) return
  const res = await fetch(`${BASE}/admin/realms/${REALM}/users/${userId}/role-mappings/realm`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type':'application/json' },
    body: JSON.stringify(roleObjs)
  })
  if (![204].includes(res.status)) {
    console.warn('Assign role result:', res.status, await res.text())
  }
}

async function upsertAttributes(token, userId, row){
  // Lấy user, merge attributes
  const res = await fetch(`${BASE}/admin/realms/${REALM}/users/${userId}`, {
    headers: { Authorization: `Bearer ${token}` }
  })
  const user = await res.json()
  user.attributes = user.attributes || {}
  user.attributes.employee_id = [row.employee_id]
  user.attributes.department = [row.department]
  user.attributes.position = [row.position]
  const res2 = await fetch(`${BASE}/admin/realms/${REALM}/users/${userId}`, {
    method: 'PUT',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type':'application/json' },
    body: JSON.stringify(user)
  })
  if (![204].includes(res2.status)) {
    console.warn('Update attributes result:', res2.status, await res2.text())
  }
}

async function main(){
  const csvPath = path.resolve(process.cwd(), 'scripts/users.csv')
  const text = await fs.readFile(csvPath, 'utf8')
  const rows = parseCSV(text)
  const token = await getToken()

  for (const row of rows){
    try {
      await createUser(token, row)
      const userId = await getUserId(token, row.email)
      if (!userId) { console.error('Cannot find user after create:', row.email); continue }
      await upsertAttributes(token, userId, row)
      await setPasswordIfEmpty(token, userId)
      await assignRoles(token, userId, row.roles)
      console.log(`✅ Synced user: ${row.email}`)
    } catch (e) {
      console.error(`❌ Failed user ${row.email}:`, e.message)
    }
  }
}

await main()
