/*
1.	Scenario: Reporte de clientes
Given: El due�o del negocio requiere conocer a sus clientes
When: requiera la informaci�n
Then: un reporte deber�a mostrar el nombre, direcci�n, tel�fono y nit
And: debe estar ordenado por nombre 
And: debe estar filtrado por las ventas del primer semestre de cada a�o.
And: debe estar filtrado por el d�a lunes de las ventas.
*/

select nombreCliente nombre, direccion,telefono,nit,
s.fecha,datename(dw,s.fecha) nombreDia,day(s.fecha) dia, 
datepart(qq,s.fecha) trimestre, datename(mm,s.fecha) nombreMes
from Clientes c
inner join Salida s on s.idCliente=c.idCliente
--where month(s.fecha) in (1,2,3,4,5,6) 
where datepart(qq,s.fecha) in (1,2)
and datename(dw,s.fecha)='Lunes'
order by nombreCliente

/*
2.	Scenario: Reporte de art�culos
Given: El due�o del negocio requiere un listado de productos
When: requiera la informaci�n
Then: deber�a mostrar el c�digo, nombre, precio, costo, existencia, marca, total en ventas, total en costos y total en utilidad 
And: debe estar ordenado por marca y nombre de art�culo
*/

select  codigo,nombre,d.precio,d.cantidad, d.costoTotal costo, existencia, m.nombreMarca marca,
d.cantidad*d.precio totalVenta, d.costoTotal*d.cantidad totalCosto,
(d.precio-d.costoTotal)*d.cantidad totalUtilidad
from Productos p
inner join marca m on p.idmarca=m.idmarca
inner join SalidaDetalle d on p.id=d.idproducto
order by m.nombreMarca,p.nombre

select p.codigo,p.nombre,p.descripcion,
avg(d.cantidad) cantidadPromedio,
sum(d.cantidad) cantidadSuma,
min(d.cantidad) cantidadMinima,
max(d.cantidad) cantidadMaximo,
sum(d.cantidad*d.precio) totalVenta, sum(d.costoTotal*d.cantidad) totalCosto,
sum((d.precio-d.costoTotal)*d.cantidad) totalUtilidad
from Productos p
inner join SalidaDetalle d on p.id=d.idproducto
group by  p.codigo,p.nombre,p.descripcion

update SalidaDetalle set costoTotal=(precio*0.6)


select p.codigo,p.nombre,s.fecha,
sum((d.precio-d.costoTotal)*d.cantidad) totalUtilidad
from Productos p
inner join SalidaDetalle d on p.id=d.idproducto
inner join Salida as s on d.idsalida=s.idsalida
where s.fecha between dateadd(MONTH,-7,getdate()) and GETDATE()
group by  p.codigo,p.nombre,s.fecha
order by p.nombre


select fecha from salida
order by fecha desc




/*
9.  Scenario: Reporte de utilidad bruta (Daniel Estupe)
Given: el due�o de un negocio requiere informaci�n de las ventas
When: requiera la informaci�n
Then: deber�a mostrar el a�o, mes, ingresos, egresos y utilidad bruta 
And: debe estar ordenado por a�o y mes
And: debe ser posible filtrar por ninguno o varios a�os y por ninguno o varios meses
*/

use ComputerDB;
declare @consulta varchar(max)
declare @anhos varchar(50)
declare @meses varchar(50)

select @anhos = '2016,2017'
select @meses = '2'

set @consulta = 'select year(fecha) as A�o,
					   datename(month, fecha) as Mes,
					   sum(sd.costoTotal) as Ingresos,
					   sum(sd.cantidad * p.costo) as Egresos,
					   sum(costoTotal - cantidad * p.costo) as Utilidad_Bruta
				from Salida s
				inner join SalidaDetalle sd on sd.idSalida = s.idSalida
				inner join Productos p on p.id = sd.idProducto
				where (len('''+ @anhos + ''') > 0) 
				and (len(''' + @meses + ''') > 0)
				and (year(fecha) in (' + @anhos + ')) 
				and month(fecha) in (' + @meses + ')
				group by year(fecha), datename(month, fecha), month(fecha)
				order by A�o desc, month(fecha) asc'
print(@consulta)
exec(@consulta)

select * from salidadetalle
