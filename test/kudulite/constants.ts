export const MEST_IMAGE_PREFIX = "mcr.microsoft.com/azure-functions/mesh";

export const DEFAULT_SRC_CONTAINER_NAME = "testsrc";

export const DEFAULT_DEST_CONTAINER_NAME = "scm-releases";

// Available mesh runtime image types
export enum RuntimeImageType {
    V2 = "V2",
    V2_PYTHON37 = "V2_PYTHON37",
    V2_NODE10 = "V2_NODE10",
    V3 = "V3",
    V3_PYTHON37 = "V3_PYTHON37",
    V3_PYTHON38 = "V3_PYTHON38",
    V3_NODE12 = "V3_NODE12"
  }
