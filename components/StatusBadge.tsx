export default function StatusBadge({value}:{value:string}){
  const label=value.replace(/_/g," ").toLowerCase().replace(/\b\w/g,c=>c.toUpperCase());
  return <span className={"badge "+value}>{label}</span>;
}
