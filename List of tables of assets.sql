--List of tables of assets

select * from dbo.FA00400 --cuentas
select * from dbo.FA00200 --depreciación periodo
select * from dbo.FA00100 --maestro de activos
select * from dbo.FA00500 --contratos leasing
select * from dbo.FA00700 --activos retirados
select * from dbo.FA00902 where assetindex in (1221,1350,1425) order by deprtodate --depreciación mensual
select * from dbo.FA40201 --maestro de clases de activos
select * from dbo.FA41600 --leasecompindx ruc de bancos arrendamiento
select * from dbo.FA49900
