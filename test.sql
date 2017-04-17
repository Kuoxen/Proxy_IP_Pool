--新放款
select lid.invest_no
		,lid.fund_id 
		,llb.custname
		,llb.custid
		,case when llb.type=0 then '新投资' when llb.type=1 then '回款再投' end as invest_type 
		,LID.arri_trade_time
		,llb.amount
		,llb.id
		,to_char(llb.create_time,'yyyy-mm-dd hh24:mi:ss') as llb_create_time
		,case llb.state when '1' then '待撮合' when '2' then '撮合中' when '3' then '部分撮合' when '4' then '满额' when '5' then '已确认' else '未知' end as lendbill_state 
		,a.apply_id
		,mtl.amount as match_amount
		,status_time.t1
		,status_time.t2
		,status_time.t3
		,status_time.t4
		,status_time.t5
		,status_time.t6
		,status_time.t7
		,status_time.t8
		,status_time.t9
		,status_time.t10
		,status_time.t11
		,status_time.t12
		,status_time.t13
		,status_time.t14
		,status_time.t15
from ZWJFBORROWER.BOR_LOANS_MAIN l
inner join 
(
	select sl.apply_id,min(sl.CREATE_TIME) as CREATE_TIME
	from ZWJFBORROWER.BOR_APPLY_STATUS_LOG sl
	left join ZWJFBORROWER.sal_apply_info a on sl.apply_id=a.apply_id
	where sl.STATUS_CODE='50-1' and TO_CHAR(a.CREATE_TIME,'yyyy-mm-dd')>＝'2016-06-07'
	group by sl.apply_id
) loan on l.apply_id=loan.apply_id
left join ZWJFBORROWER.sal_apply_info a on l.apply_id=a.apply_id
left join ZWJFBORROWER.BOR_CONTRACT c on l.contract_id=c.contract_id
LEFT JOIN ZWJFBORROWER.BOR_BORROWER B ON A.APPLY_ID=B.APPLY_ID
left join ZWJFLENDER.LEN_MATCH_TRADE mt on c.make_match_no=mt.matchid
left join ZWJFLENDER.LEN_MATCH_TRADE_LIST mtl on mt.id=MTL.MATCHTRADEID
left join ZWJFLENDER.LEN_LEND_BILL llb on mtl.LENDBILLID=llb.id
left join ZWJFLENDER.LEN_INVEST_DTL lid on lid.invest_no=llb.INVESTNO
left join
(
	select sl.apply_id
			,max(case when sl.status_code='30-2' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t1 --待资金方审核1
			,max(case when sl.status_code='31-2' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t2 --资金方异议沟通中1
			,max(case when sl.status_code in ('10-2','10-1') then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t3 --待签合同1
			,max(case when sl.status_code='25-1' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t4 --已撮合待下载1
			,max(case when sl.status_code='20-1' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t5 --合同生成待确认1
			,max(case when sl.status_code='20-2' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t6 --待上传签约资料1
			,max(case when sl.status_code='30-1' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t7 --合同已签待审核1
			,max(case when sl.status_code='20-5' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t8 --驳回修改银行卡信息1
			,max(case when sl.status_code='20-3' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t9 --重新上传签约资料
			,max(case when sl.status_code='40-1' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t10 --待放款1
			,max(case when sl.status_code='90-2' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t11 --放款失败1
			,max(case when sl.status_code='40-2' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t12 --放款撤销1			
			,max(case when sl.status_code='50-1' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t13 --完成放款
			,max(case when sl.status_code like '19-%' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t14 --拒贷
			,max(case when sl.status_code='18-1' or sl.remark='销售定时器自动冻结处理！' then TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') end) as t15 --冻结1
	from
	(
		select sl.apply_id
				,sl.STATUS_CODE
				,sl.CREATE_TIME
				,sl.remark
		from ZWJFBORROWER.BOR_APPLY_STATUS_LOG sl 
		inner join
		(
			select l.apply_id
			from ZWJFBORROWER.BOR_LOANS_MAIN l
			inner join 
			(
				select sl.apply_id,min(sl.CREATE_TIME) as CREATE_TIME
				from ZWJFBORROWER.BOR_APPLY_STATUS_LOG sl
				left join ZWJFBORROWER.sal_apply_info a on sl.apply_id=a.apply_id
				where sl.STATUS_CODE='50-1' and TO_CHAR(a.CREATE_TIME,'yyyy-mm-dd')>＝'2016-06-07' 
				group by sl.apply_id
			) loan on l.apply_id=loan.apply_id
			left join ZWJFBORROWER.sal_apply_info a on l.apply_id=a.apply_id
			where TO_CHAR(a.CREATE_TIME,'yyyy-mm-dd')>＝'2016-06-07'  
					and l.loans_status in (1,5)
		) t on sl.apply_id=t.apply_id
	) sl 
	group by sl.apply_id	
) status_time 
on a.apply_id=status_time.apply_id
where l.loans_status in (1,5) and TO_CHAR(loan.create_time,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(loan.create_time,'yyyy-mm-dd')<='2017-03-10'



----债权转让


select td.buyer_INVEST_ID
		,to_char(llb.create_time,'yyyy-mm-dd hh24:mi:ss') as buyer_lendbill_time
		,lid.fund_id 
		,llb.custname
		,llb.custid
		,case when llb.type=0 then '新投资' when llb.type=1 then '回款再投' end as invest_type 
		,LID.arri_trade_time
		,llb.amount
		,td.sell_AMT
		,lsc.sell_apply_id
		,to_char(t.create_time,'yyyy-mm-dd hh24:mi:ss') as t_create_time
		,'转让成功' as trans_state
		,to_char(t.SURE_DATE,'yyyy-mm-dd hh24:mi:ss')
from ZWJFLENDER.LEN_TRANSFER t
left join ZWJFLENDER.LEN_TRANSFER_DTL td on td.LOAN_TRANSFER_MODEL_ID=t.id
left join ZWJFLENDER.LEN_LEND_BILL llb on td.lend_bill_id=llb.id
left join ZWJFLENDER.LEN_INVEST_DTL lid on lid.invest_no=llb.INVESTNO
left join (select * from ZWJFLENDER.len_sell_confirm where state = 13) lsc on t.seller_invest_id=lsc.invest_no
where TO_CHAR(t.SURE_DATE,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(t.SURE_DATE,'yyyy-mm-dd')<='2017-03-10'




---续投

select quit_invest.invest_no as end_invest_no
		,quit_invest.plan_invest_amt as end_invest_amt
		,quit_invest.over_date
		,quit_invest.if_quit
		,quit_invest.invest_end_date
		,new_invest.invest_no
		,new_invest.trade_time
		,new_invest.plan_invest_amt
		,new_invest.product_name
from 
(
	select lid.invest_no
			,lid.plan_invest_amt
			,TO_CHAR(lid.over_date,'yyyy-mm-dd hh24:mi:ss') as over_date
			,case when lsc.state=13 then '是' else '否' end as if_quit
			,TO_CHAR(lid.invest_end_date,'yyyy-mm-dd hh24:mi:ss') as invest_end_date
			,lid.lender_info_id
			,row_number() OVER(PARTITION BY lid.lender_info_id ORDER BY lid.invest_end_date) as rn
	from ZWJFLENDER.LEN_INVEST_DTL lid
	left join ZWJFLENDER.len_sell_confirm lsc on lsc.invest_no=lid.invest_no
	where TO_CHAR(lid.over_date,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(lid.over_date,'yyyy-mm-dd')<='2017-03-10'
) quit_invest
left join
(
	select quit_invest.lender_info_id
			,new_invest.rn as new_rn
			,min(quit_invest.rn) as quit_rn
	from
	(
		select lid.invest_no
				,lid.plan_invest_amt
				,TO_CHAR(lid.over_date,'yyyy-mm-dd hh24:mi:ss') as over_date
				,case when lsc.state=13 then '是' else '否' end as if_quit
				,TO_CHAR(lid.invest_end_date,'yyyy-mm-dd hh24:mi:ss') as invest_end_date
				,lsc.amount
				,lid.lender_info_id
				,sum(lsc.amount) OVER(PARTITION BY lid.lender_info_id ORDER BY lid.invest_end_date) as accu_end_amount
				,row_number() OVER(PARTITION BY lid.lender_info_id ORDER BY lid.invest_end_date) as rn
		from ZWJFLENDER.LEN_INVEST_DTL lid
		left join ZWJFLENDER.len_sell_confirm lsc on lsc.invest_no=lid.invest_no
		where TO_CHAR(lid.over_date,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(lid.over_date,'yyyy-mm-dd')<='2017-03-10'
	) quit_invest
	left join 
	(
		select lid.invest_no
				,to_char(lid.trade_time,'yyyy-mm-dd hh24:mi:ss') as trade_time
				,lid.plan_invest_amt
				,PRD.DISPLAYNAME as product_name
				,lid.lender_info_id
				,sum(lid.plan_invest_amt) OVER(PARTITION BY lid.lender_info_id ORDER BY lid.trade_time) as accu_invest_amount
				,row_number() OVER(PARTITION BY lid.lender_info_id ORDER BY lid.trade_time) as rn
		from ZWJFLENDER.LEN_INVEST_DTL lid 
		left join 
		(
			SELECT DICTKEY,VALUE2,VALUE1,DISPLAYNAME 
			FROM ZWJFLENDER.COMP_DICT 
			WHERE PATH LIKE '/APP_DICT/LENDER/INVESTPRODUCTIONS/%' AND VALUE2 IS NOT NULL
		) PRD ON LID.REINVEST=PRD.DICTKEY  
		inner join 
		(
			select lid.lender_info_id
					,min(lid.invest_end_date) as invest_end_date
			from ZWJFLENDER.LEN_INVEST_DTL lid
			left join ZWJFLENDER.len_sell_confirm lsc on lsc.invest_no=lid.invest_no
			where TO_CHAR(lid.over_date,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(lid.over_date,'yyyy-mm-dd')<='2017-03-10' and lsc.state=13
			group by lid.lender_info_id
		) t 
		on lid.lender_info_id=t.lender_info_id and lid.trade_time>t.invest_end_date
		where TO_CHAR(lid.trade_time,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(lid.trade_time,'yyyy-mm-dd')<='2017-03-10'
	) new_invest 
	on quit_invest.lender_info_id=new_invest.lender_info_id and quit_invest.invest_end_date<new_invest.trade_time
	and quit_invest.accu_end_amount>=new_invest.accu_invest_amount
	group by quit_invest.lender_info_id,new_invest.rn
) rn 
on quit_invest.rn=rn.quit_rn and quit_invest.lender_info_id=rn.lender_info_id
left join 
(
	select lid.invest_no
			,to_char(lid.trade_time,'yyyy-mm-dd hh24:mi:ss') as trade_time
			,lid.plan_invest_amt
			,PRD.DISPLAYNAME as product_name
			,lid.lender_info_id
			,row_number() OVER(PARTITION BY lid.lender_info_id ORDER BY lid.trade_time) as rn
	from ZWJFLENDER.LEN_INVEST_DTL lid 
	left join 
	(
		SELECT DICTKEY,VALUE2,VALUE1,DISPLAYNAME 
		FROM ZWJFLENDER.COMP_DICT 
		WHERE PATH LIKE '/APP_DICT/LENDER/INVESTPRODUCTIONS/%' AND VALUE2 IS NOT NULL
	) PRD ON LID.REINVEST=PRD.DICTKEY  
	inner join 
	(
		select lid.lender_info_id
				,min(lid.invest_end_date) as invest_end_date
		from ZWJFLENDER.LEN_INVEST_DTL lid
		left join ZWJFLENDER.len_sell_confirm lsc on lsc.invest_no=lid.invest_no
		where TO_CHAR(lid.over_date,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(lid.over_date,'yyyy-mm-dd')<='2017-03-10' and lsc.state=13
		group by lid.lender_info_id
	) t 
	on lid.lender_info_id=t.lender_info_id and lid.trade_time>t.invest_end_date
	where TO_CHAR(lid.trade_time,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(lid.trade_time,'yyyy-mm-dd')<='2017-03-10'
) new_invest 
on rn.lender_info_id=new_invest.lender_info_id and rn.new_rn=new_invest.rn

---撮合

select lid.invest_no
		,lli.name
		,to_char(lid.create_time,'yyyy-mm-dd hh24:mi:ss')
		,llb.id
		,case when llb.type=0 then '新投资' when llb.type=1 then '回款再投' end as invest_type 
		,LLB.amount
		,to_char(llb.create_time,'yyyy-mm-dd hh24:mi:ss')
		,mtl.id as match_id 
		,mtl.amount as match_amount
		,to_char(mtl.create_time,'yyyy-mm-dd hh24:mi:ss')
		,case when mtl.state is null then '成功' else '撤销' end as match_state
		,case when c.if_new=1 then '新放款' else '受让债权' end as match_type
		,to_char(unmatch.create_time,'yyyy-mm-dd hh24:mi:ss') as unmatch_time
		,case when mtl.state is not null then null else to_char(c.end_date,'yyyy-mm-dd hh24:mi:ss') end as match_time
from ZWJFLENDER.LEN_INVEST_DTL lid 
left join ZWJFLENDER.len_lender_info lli on LID.LENDER_INFO_ID=LLI.ID
left join ZWJFLENDER.LEN_LEND_BILL llb on lid.invest_no=llb.INVESTNO
left join ZWJFLENDER.LEN_MATCH_TRADE_LIST mtl on mtl.LENDBILLID=llb.id
left join ZWJFLENDER.LEN_MATCH_TRADE mt on mt.id=MTL.MATCHTRADEID
LEFT JOIN 
(
	select c.MAKE_MATCH_NO
			,c.contract_id
			,1 as len_scale
			,1 as if_new
			,c.CONTRACT_SIGN_DATE as asset_start_time
			,loan.CREATE_TIME as end_date
	from ZWJFBORROWER.BOR_CONTRACT C
	left join
	(
		select sl.apply_id,min(sl.CREATE_TIME) as CREATE_TIME
		from ZWJFBORROWER.BOR_APPLY_STATUS_LOG sl
		left join ZWJFBORROWER.sal_apply_info a on sl.apply_id=a.apply_id
		where sl.STATUS_CODE='50-1' and TO_CHAR(a.CREATE_TIME,'yyyy-mm-dd')>＝'2016-06-07' and TO_CHAR(sl.CREATE_TIME,'yyyy-mm-dd hh24:mi:ss')<＝TO_CHAR(SYSDATE,'yyyy-mm-dd')||' 18:30:00'
		group by sl.apply_id
	) loan on c.apply_id=loan.apply_id
	union all 
	select t.TRADE_ID as MAKE_MATCH_NO
			,c.contract_id
			,t.HOLD_CONTRACT_SCAL*t.TRANSFER_SCALE as len_scale
			,0 as if_new 
			,null as asset_start_time
			,t.SURE_DATE as end_date
	from ZWJFLENDER.LEN_TRANSFER t
	left join zwjfborrower.bor_contract c on t.loan_receipt_no=c.contract_id		
) C ON MT.MATCHID=C.MAKE_MATCH_NO  
left join 
(
	select a.*
	from
	(
		select mtl.id
				,sl.create_time
				,row_number() OVER(PARTITION BY mtl.id ORDER BY sl.CREATE_TIME) as rn
		from ZWJFLENDER.LEN_MATCH_TRADE_LIST mtl 
		left join ZWJFLENDER.LEN_MATCH_TRADE mt on mt.id=MTL.MATCHTRADEID
		LEFT JOIN 
		(
			select c.MAKE_MATCH_NO
					,c.contract_id
					,1 as len_scale
					,1 as if_new
					,c.CONTRACT_SIGN_DATE as asset_start_time
					,c.apply_id
			from ZWJFBORROWER.BOR_CONTRACT C

			union all 
			select t.TRADE_ID as MAKE_MATCH_NO
					,c.contract_id
					,t.HOLD_CONTRACT_SCAL*t.TRANSFER_SCALE as len_scale
					,0 as if_new 
					,null as asset_start_time
					,c.apply_id
			from ZWJFLENDER.LEN_TRANSFER t
			left join zwjfborrower.bor_contract c on t.loan_receipt_no=c.contract_id		
		) C ON MT.MATCHID=C.MAKE_MATCH_NO  
		left join 
		(
			SELECT APPLY_ID,CREATE_TIME
			FROM ZWJFBORROWER.BOR_APPLY_STATUS_LOG
			WHERE REMARK='执行撤销撮合成功!' OR STATUS_CODE='90-1'	
		) sl 
		on c.apply_id=sl.apply_id and mtl.create_time<sl.create_time
		where mtl.state is not null
	) a 
	where a.rn=1
) unmatch
on mtl.id=unmatch.id
where to_char(llb.create_time,'yyyy-mm-dd')>='2017-02-06' and TO_CHAR(llb.create_time,'yyyy-mm-dd')<='2017-03-10'












