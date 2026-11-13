export default function StatCard({label,value,detail,icon,bar}:{label:string,value:string|number,detail:string,icon:string,bar?:number}){
  return <div className="stat-card" style={{"--bar":(bar??48)+"%"} as React.CSSProperties}>
    <div className="stat-top"><span>{label}</span><span className="stat-icon">{icon}</span></div>
    <div className="stat-value">{value}</div><div className="stat-foot">{detail}</div><i className="stat-line"/>
  </div>;
}
