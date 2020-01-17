------------------------------------------------------------------------
--Exemplo SQL de ordenação aleatória

select top 10 campo
  from dbo.tabela
 order by newid()
------------------------------------------------------------------------
-- Exemplo SQL para obter os últimos 7 dias:

select Top 7 CONVERT(VARCHAR(10), DATEADD(DAY, -1 * ROW_NUMBER() OVER(ORDER BY Id), getdate()), 121) from sysobjects
------------------------------------------------------------------------
-- Exemplo SQL para obter o mês e ano anterior e posterior ao informado

declare @MesAno int

set @MesAno = 201912

if (OBJECT_ID('tempdb..#Referencia') IS NOT NULL)
    DROP TABLE #Referencia

create table #Referencia (dtReferencia int)

if (right(@MesAno, 2) = '01')
    insert into #Referencia values (@MesAno - 89)
else
    insert into #Referencia values (@MesAno - 1)

insert into #Referencia values (@MesAno)

if (right(@MesAno, 2) = '12')
    insert into #Referencia values (@MesAno + 89)
else
    insert into #Referencia values (@MesAno +1)

select * from #Referencia

------------------------------------------------------------------------
-- Exemplo paara obter o primeiro e último sábado de um mês informado

declare @Sabado_1 date, @Sabado_2 date

exec DBO.SABADOS '2019-07', @PrimeiroSabado = @Sabado_1 output, @UltimoSabado = @Sabado_2 output

select @Sabado_1 '@Sabado_1', @Sabado_2 '@Sabado_2'


ALTER PROCEDURE [dbo].sabados
       @MesReferencia varchar(7)
     , @PrimeiroSabado varchar(8) = null output
     , @UltimoSabado varchar(8) = null output
AS
begin

	if (len(@MesReferencia) = 6)
		set @MesReferencia = SUBSTRING(@MesReferencia, 1, 4) + '-' + SUBSTRING(@MesReferencia, 5, 2)


	if (OBJECT_ID('tempdb..#filtro') IS NOT NULL)
		DROP TABLE #filtro

	create table #filtro(data date, dia varchar(15), ordem smallint)

    insert into #filtro
    select *
      from (
        select data,
               datename( weekday, data ) as wkdy,
               row_number( ) over ( partition by datepart( month, data ), datename( weekday, data ) order by data ) as rn_dy_mth
        from (
            select dateadd( day, rn, cast( @MesReferencia + '-01' as date ) ) as data
            from (
                select row_number() over( order by object_id ) - 1 as rn
                from sys.columns
                ) as rn
            ) as dy
        ) as dy_mth
    where wkdy = 'Saturday' 
      and convert(varchar(7), data, 121) = @MesReferencia
    order by data

    declare @qtde smallint
    select @qtde = count(1) from #filtro

    if (@qtde > 4)
    begin
        select @PrimeiroSabado = convert(varchar(8), data, 112) from #filtro where ordem = 2
        select @UltimoSabado = convert(varchar(8), data, 112) from #filtro where ordem = 5
    end
    else
    begin
        select @PrimeiroSabado = convert(varchar(8), data, 112) from #filtro where ordem = 1
        select @UltimoSabado = convert(varchar(8), data, 112) from #filtro where ordem = 4
    end

	--set @PrimeiroSabado = replace(@PrimeiroSabado, '-', '')
	--set @UltimoSabado = replace(@UltimoSabado, '-', '')

end
------------------------------------------------------------------------
-- Verificação de caracteres inválidos
/*
char(9): tab
char(10): line feed
char(13): carriage return
char(32): space
*/
DECLARE @position int, @string char(20);

SET @position = 1;
SET @string = 'AB - CDEFGHIJ'; -- hifen curto aqui é o char(45)
WHILE @position <= DATALENGTH(@string)
   BEGIN
   SELECT ASCII(SUBSTRING(@string, @position, 1)),
      CHAR(ASCII(SUBSTRING(@string, @position, 1)))
   SET @position = @position + 1
   END;
GO

DECLARE @position int, @string char(20);

SET @position = 1;
SET @string = 'BZ – ASDFASFDASDFASDF'; -- hifen longo aqui é o char(150)
WHILE @position <= DATALENGTH(@string)
   BEGIN
   SELECT ASCII(SUBSTRING(@string, @position, 1)),
      CHAR(ASCII(SUBSTRING(@string, @position, 1)))
   SET @position = @position + 1
   END;
GO

--------------------------

       if (OBJECT_ID('tempdb..#filtro') IS NOT NULL)
              DROP TABLE #filtro

       create table #filtro(texto varchar(100))

    insert into #filtro values ('PROD01')
    insert into #filtro values ('PROD02')
    insert into #filtro values ('PROD03')
    insert into #filtro values ('PROD01/PROD02/PROD04')

    insert into #filtro
    select value from string_split((select texto from #filtro where charindex('/', texto) > 0), '/')


    select 'Antes', * from #filtro

    delete from #filtro
     where charindex('/', texto) > 0;

    with duplicados as(
        select fil.texto, row_number() over(partition by fil.texto order by fil.texto) as id
          from #filtro fil
    )
    delete from duplicados where id > 1;


    select 'Depois', * from #filtro
