# 常用的云计算安全评估框架

### 标题

3. 云安全评估

---

### 正文说明

2021年1月，云安全联盟CSA发布了云控制矩阵v4（CCM4.0）。包括17个控制域中的197个控制目标，全方位涵盖了云计算技术的安全领域。它可以用作对云计算实施的系统性评估工具，也可以作为云计算供应链中各角色与安全控制关系的指导。是特定于云的安全控制元框架，框架映射到与安全、隐私等相关的领先的标准、最佳实践和法规。

---

### 17个控制域
| 缩写 | 全称 |
|------|------|
| A&A | Audit & Assurance |
| AIS | Application & Interface Security |
| BCR | Business Continuity Mgmt & Op Resilience |
| CCC | Change Control & Configuration Management |
| CEK | Cryptography, Encryption and Key Management |
| DCS | Datacenter Security |
| DSP | Data Security and Privacy |
| GRM | Governance, Risk Management and Compliance |
| HRS | Human Resources Security |
| IAM | Identity & Access Management |
| IPY | Interoperability & Portability |
| IVS | Infrastructure & Virtualization |
| LOG | Logging and Monitoring |
| SEF | Sec. Incident Mgmt, E-Disc & Cloud Forensics |
| STA | Supply Chain Mgmt, Transparency & Accountability |
| TVM | Threat & Vulnerability Management |
| UEP | Universal EndPoint Management |

---

### 来源
来源：云安全联盟大中华区（CSA GCR）云控制矩阵 https://c-csa.cn/research/results-detail/i-1640/


### 标题
3. 云安全评估

---

### 说明文本
ENISA, 2009年发布了《Cloud Computing Security Risk Assessment》。

---

### 风险分类列表
#### Policy and organizational risks
- R.1 Lock-in
- R.2 Loss of governance
- R.3 Compliance challenges
- R.4 Loss of business reputation due to co-tenant activities
- R.5 Cloud service termination or failure
- R.6 Cloud provider acquisition
- R.7 Supply chain failure

#### Technical risks
- R.8 Resource exhaustion (under or over provisioning)
- R.9 Isolation failure
- R.10 Cloud provider malicious insider - abuse of high privilege roles
- R.11 Management interface compromise (manipulation, availability of infrastructure)
- R.12 Intercepting data in transit
- R.13 Data leakage on up/download, intra-cloud
- R.14 Insecure or ineffective deletion of data
- R.15 Distributed denial of service (DDoS)
- R.16 Economic denial of service (EDOS)
- R.17 Loss of encryption keys
- R.18 Undertaking malicious probes or scans
- R.19 Compromise service engine
- R.20 Conflicts between customer hardening procedures and cloud environment

#### Legal risks
- R.21 Subpoena and e-discovery
- R.22 Risk from changes of jurisdiction
- R.23 Data protection risks
- R.24 Licensing risks

#### Risks not specific to the cloud
- R.25 Network breaks
- R.26 Network management (ie, network congestion / mis-connection)
- R.27 Modifying network traffic
- R.28 Privilege escalation
- R.29 Social engineering attacks (ie, impersonation)
- R.30 Loss or compromise of operational logs
- R.31 Loss or compromise of security logs (manipulation of forensic in...)
- R.32 Backups lost, stolen
- R.33 Unauthorized access to premises (including physical access to m... facilities)
- R.34 Theft of computer equipment
- R.35 Natural disasters

---

### 来源
来源：ENISA 云计算安全风险评估 https://www.enisa.europa.eu/publications/cloud-computing-risk-assessment

（右侧图表为《FIGURE 2. RISK DISTRIBUTION》，包含概率-影响矩阵，标注了R.1至R.35的分布；右下角为PPT播放控制菜单，内容略）



### 图示部分
中心文字：
`Planning a Cloud Migration?`

环形评估维度（顺时针）：
1.  Local Data Center Availability
2.  Security
3.  Resilience
4.  Data Storage and Archival
5.  Configuration Management/ CI/CD Tools
6.  Accreditation and Auditing
7.  Wider Availability of Solution Components
8.  Adaptability
9.  Portability
10. Operations/ SLAs

---

### 右侧文字
印度InfoSys的云迁移评估框架
1.  Local Data Center Availability
2.  Security
3.  Resilience
4.  Data Storage and Archival
5.  Configuration Management/ CI/CD Tools
6.  Accreditation and Auditing
7.  Wider Availability of Solution Components
8.  Adaptability
9.  Portability
10. Operations/SLAs

---

### 来源
来源：印度InfoSys的云迁移评估框架
`https://www.infosys.com/Oracle/white-papers/Documents/cloud-migration-assessment-framework.pdf`