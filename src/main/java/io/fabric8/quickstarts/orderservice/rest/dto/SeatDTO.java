package io.fabric8.quickstarts.orderservice.rest.dto;

import java.io.Serializable;
import io.fabric8.quickstarts.orderservice.model.Seat;
import javax.persistence.EntityManager;

public class SeatDTO implements Serializable
{

   private NestedSectionDTO section;
   private int rowNumber;
   private int number;

   public SeatDTO()
   {
   }

   public SeatDTO(final Seat entity)
   {
      if (entity != null)
      {
         this.section = new NestedSectionDTO(entity.getSection());
         this.rowNumber = entity.getRowNumber();
         this.number = entity.getNumber();
      }
   }

   public Seat fromDTO(Seat entity, EntityManager em)
   {
      if (entity == null)
      {
         entity = new Seat();
      }
      return entity;
   }

   public NestedSectionDTO getSection()
   {
      return this.section;
   }

   public void setSection(final NestedSectionDTO section)
   {
      this.section = section;
   }

   public int getRowNumber()
   {
      return this.rowNumber;
   }

   public void setRowNumber(final int rowNumber)
   {
      this.rowNumber = rowNumber;
   }

   public int getNumber()
   {
      return this.number;
   }

   public void setNumber(final int number)
   {
      this.number = number;
   }
}