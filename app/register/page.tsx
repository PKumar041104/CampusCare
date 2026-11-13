import AuthRegisterForm from "../../components/AuthRegisterForm";
export default function RegisterPage({searchParams}:{searchParams:{error?:string}}){
 return <main className="auth"><section className="auth-visual"><div className="auth-brand">CampusCare</div><div className="auth-copy"><small>JOIN YOUR CAMPUS</small><h2>Better spaces<br/>start <em>together.</em></h2><p>Create your account to report maintenance needs and track progress.</p></div><div className="auth-footer">One campus. Every request. Clear progress.</div></section><section className="auth-panel"><AuthRegisterForm error={searchParams?.error}/></section></main>;
}
