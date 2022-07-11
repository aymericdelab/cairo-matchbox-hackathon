import styled from "styled-components";
import { styled as muistyled } from "@mui/system";

export const Wrapper = styled.div`
  display: block;
  float: right;
`;

export const SectionRoot = styled.div`
  display: flex;
  flex-direction: column;
`;

export const Section = styled.div`
  padding-bottom: "2rem";
`;

export const SectionTitle = styled.h3``;

export const ActionRoot = styled.div`
  display: "flex";
  justify-content: flex-start;
  gap: 4rem;
  margin-bottom: 2rem;
`;

export const Button = muistyled("button")({
  background: "black",
  border: "1px solid var(--ifm-color-primary)",
  padding: "1rem",
  borderRadius: "10px",
  cursor: "pointer",
  color: "white",
  "&:hover": {
    boxShadow: "0px 5px 5px rgba(0, 0, 0, 0.2)",
  },
});
