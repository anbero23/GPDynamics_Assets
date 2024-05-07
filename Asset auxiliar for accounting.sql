--Query para armar el libro contable de activo fijo según norma peruana

with mov_mensual as (
select	assetindex indice_activo
		,fa_doc_number documento_dep
		,fayear año
		,faperiod mes
		--,deprfromdate fecha_desde
		,year(deprtodate)*100+month(deprtodate) fecha_hasta
		,sum(amount) monto
		,case transaccttype when 1 then 'reserva'
		when 2 then 'depreciacion'
		when 3 then 'costo'
		when 4 then 'proceeds'
		when 5 then 'recognized gain loss'
		when 6 then 'non recognized gain loss'
		when 7 then 'clearing'
		end tipo_mov
from dbo.FA00902
where /*transaccttype=2 and*/ assetindex=344
group by assetindex,fa_doc_number,fayear,faperiod,year(deprtodate)*100+month(deprtodate),transaccttype
)

--,mov_acum as (
select	indice_activo
		,año
		,mes
		,tipo_mov
		,sum(monto) monto_periodo
		,sum(monto) over(partition by año,indice_activo,tipo_mov order by mes asc rows unbounded preceding) monto_acum_año
		,sum(monto) over(partition by año,indice_activo,tipo_mov order by mes asc rows between unbounded preceding and 1 preceding) monto_acum_anterior
		,(sum(monto) over(partition by indice_activo,tipo_mov order by año,mes asc) -
		 sum(monto) over(partition by año,indice_activo,tipo_mov order by mes asc rows unbounded preceding)) monto_ini_ejercicio
		,sum(monto) over(partition by indice_activo,tipo_mov order by año,mes asc) monto_acumulada
from mov_mensual a
group by indice_activo,año,mes,monto,tipo_mov
)

,detalle_acum as (
select	b.año*100+b.mes id_tiempo
		,b.año
		,b.mes
		,sum(case when tipo_mov='costo' then monto_ini_ejercicio else 0 end) costo_ini_ejercicio
		,sum(case when tipo_mov='costo' then monto_periodo else 0 end) costo_periodo
		,sum(case when tipo_mov='costo' then monto_acumulada else 0 end) costo_acumulado
		,sum(case when tipo_mov='depreciacion' then monto_ini_ejercicio else 0 end) depre_ini_ejercicio
		,sum(case when tipo_mov='depreciacion' then monto_acum_anterior else 0 end) depre_acum_anterior
		,sum(case when tipo_mov='depreciacion' then monto_periodo else 0 end) depre_periodo
		,sum(case when tipo_mov='depreciacion' then monto_acum_año else 0 end) depre_acum_año
		,sum(case when tipo_mov='depreciacion' then monto_acumulada else 0 end) depre_acumulada
		,case when year(a.fecha_retiro)=b.año then a.costo_inicial_ejercicio else 0 end dep_retiro_periodo
from (select distinct año,mes,id_tiempo_mes from gestion.dbo.dim_fecha where año between 2008 and 2022) z
cross join detalle_activos_2 a
left join mov_acum b
	on b.indice_activo=a.indice_activo and z.año=b.año and z.mes=b.mes
)

,detalle_activos as (
SELECT A.[ASSETINDEX] indice_activo
	  ,B.ASSETID id_activo
	  ,B.ASSETDESC descripcion
	  ,B.EXTASSETDESC descripcion2
	  ,B.SHRTNAME OT
	  ,B.ASSETCLASSID clase_id
	  ,g.assetclassiddesc clase_nombre
	  ,B.LOCATNID ubicacion
	  ,B.ACQDATE fecha_adquisicion
      ,[PLINSERVDATE] fecha_servicio
      ,A.[DELETEDATE] fecha_delete
	  ,case B.ASSETSTATUS when 1 then 'activo'
	  when 2 then 'eliminado'
	  when 3 then 'parcialmente abierto'
	  when 4 then 'retirado'
	  end estado_activo
	  ,H.RETIREMENTDATE fecha_retiro
      ,[DEPRBEGDATE] fecha_inicio_dep
      ,[FULLYDEPRFLAG] boolean_full_dep
      ,[FULLYDEPRDATE] fecha_full_dep
      ,[ORIGINALLIFEYEARS] tiempo_dep_año
      ,[ORIGINALLIFEDAYS]  tiempo_dep_dias
      ,[REMAININGLIFEYEARS] tiempo_restante_año
      ,[REMAININGLIFEDAYS] tiempo_restante_dias
      ,[DEPRTODATE] tiempo_calculo_dep
	  ,B.ACQUISITION_COST costo_adquisicion
      ,[BEGINYEARCOST] costo_inicial_ejercicio
      ,[BAGINSALVAGE] costo_residual
      ,[BEGINRESERVE] dep_inicial_ejercicio
      ,[COSTBASIS] costo_acumulado
      ,[CURRUNDEPRAMT] dep_periodo_mes
      ,[PREVRUNDEPRAMT] dep_anterior_mes
      ,[YTDDEPRAMT] dep_acum_año
	  ,YTDDEPRAMT-CURRUNDEPRAMT dep_anterior_acum
	  ,ltddepramt-ytddepramt dep_ini_ejercicio
      ,[LTDDEPRAMT] dep_acum_vida
      ,[NETBOOKVALUE] valor_libro
	  ,C.ACTNUMBR_1 deprec_EERR
	  ,C.ACTNUMBR_2 ceco_deprec
	  ,D.ACTNUMBR_1 deprec_ESF
	  ,E.ACTNUMBR_1 costo_ESF
	  --SELECT *
  FROM [dbo].[FA00200] A --where assetindex in (344,1221)
left JOIN dbo.FA00100 B 
	on A.ASSETINDEX=B.ASSETINDEX
left join dbo.FA00400 F
	on A.ASSETINDEX=F.ASSETINDEX
left join [dbo].[GL00100] c
	on F.deprexpacctindx=c.actindx
left join [dbo].[GL00100] d
	on F.DEPRRESVACCTINDX=d.actindx
left join [dbo].[GL00100] e
	on F.ASSETCOSTACCTINDX=e.actindx
left join dbo.FA40201 g
	on b.assetclassid=g.assetclassid
left join dbo.FA00700 h
	on a.assetindex=h.assetindex
WHERE b.assetid in (/*'AFLPLA000328',*/
'AFLPLA001115')
)

,detalle_activos_2 as (
SELECT indice_activo
	  ,id_activo
	  ,descripcion
	  ,descripcion2
	  ,OT
	  ,clase_id
	  ,clase_nombre
	  ,ubicacion
	  ,fecha_adquisicion
      ,fecha_servicio
      ,fecha_delete
	  ,estado_activo
	  ,fecha_retiro
      ,fecha_inicio_dep
      ,tiempo_dep_año
      ,tiempo_restante_año
	  ,costo_adquisicion
      ,costo_residual
	  ,deprec_EERR
	  ,ceco_deprec
	  ,deprec_ESF
	  ,costo_ESF
from detalle_activos
)

select	b.año*100+b.mes id_tiempo
		,b.año
		,b.mes
		,a.id_activo
		,a.descripcion
		,a.descripcion2
		,a.OT
		,a.clase_id
		,a.clase_nombre
		,a.ubicacion
		,a.fecha_adquisicion
		,a.fecha_servicio
		,case when year(a.fecha_adquisicion)<=b.año then a.costo_adquisicion else 0 end costo_adquisicion
		,a.costo_residual
		,a.costo_inicial_ejercicio
		,case when year(a.fecha_adquisicion)=b.año then costo_adquisicion else 0 end monto_traspaso
		,case when year(a.fecha_retiro)=b.año then costo_adquisicion else 0 end monto_retiro
		,case when year(a.fecha_adquisicion)<=b.año then a.costo_adquisicion else 0 end +
		 case when year(a.fecha_adquisicion)=b.año then costo_adquisicion else 0 end +
		 case when year(a.fecha_retiro)=b.año then costo_adquisicion else 0 end
		,b.dep_ini_ejercicio
		,b.dep_acum_anterior
		,b.dep_periodo
		,case when year(a.fecha_retiro)=b.año then a.costo_inicial_ejercicio else 0 end dep_retiro_periodo
from (select distinct año,mes,id_tiempo_mes from gestion.dbo.dim_fecha where año between 2008 and 2022) z
cross join detalle_activos_2 a
left join mov_acum b
	on b.indice_activo=a.indice_activo and z.año=b.año and z.mes=b.mes

