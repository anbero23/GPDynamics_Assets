--Detalle de activos

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
